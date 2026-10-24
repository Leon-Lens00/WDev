#!/usr/bin/env python3
"""Project-local read-only Warcraft III Classic 1.27b inspectors."""
import sys

# Prevent bytecode writes even when callers omit -B.
sys.dont_write_bytecode = True

import argparse

from binary import KINDS, inspect_imports, inspect_objects
from core import Rejected, serialize
from doctor import inspect_doctor
from sources import inspect_sources


class Parser(argparse.ArgumentParser):
    def error(self, message):
        raise Rejected('arguments', message)


def parser():
    cli = Parser(description=__doc__)
    commands = cli.add_subparsers(dest='action', required=True)
    doctor = commands.add_parser('doctor', help='Presence checks only; no external programs or archive hashes.')
    doctor.add_argument('--config', metavar='PROJECT_JSON',
                        help='Optional bounded project profile; see workshop.example.json.')
    sources = commands.add_parser('sources', help='Lexical JASS/vJASS navigation, not semantic validation.')
    sources.add_argument('path', help='Project .j/.jass/.vjass file or bounded directory (no symlinks).')
    objects = commands.add_parser('objects', help='Inspect an extracted Classic version-2 object member.')
    objects.add_argument('kind', choices=KINDS, help='Explicit format; no metadata type inference.')
    objects.add_argument('path', help='Project-contained extracted object member, not an MPQ/map.')
    imports = commands.add_parser('imports', help='Inspect extracted version-1 war3map.imp; no asset reads.')
    imports.add_argument('path', help='Project-contained extracted import manifest.')
    return cli


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    action = argv[0] if argv and argv[0] in ('doctor', 'sources', 'objects', 'imports') else None
    try:
        args = parser().parse_args(argv)
        if args.action == 'doctor':
            result = inspect_doctor(args.config)
        elif args.action == 'sources':
            result = inspect_sources(args.path)
        elif args.action == 'objects':
            result = inspect_objects(args.kind, args.path)
        else:
            result = inspect_imports(args.path)
        output, status = serialize(action, result=result)
    except Rejected as error:
        output, status = serialize(action, error=error)
    except OSError:
        output, status = serialize(action, error=Rejected('io', 'Input cannot be read.'))
    except (ValueError, RecursionError):
        output, status = serialize(action, error=Rejected('input', 'Invalid input.'))
    print(output)
    return status


if __name__ == '__main__':
    sys.exit(main())
