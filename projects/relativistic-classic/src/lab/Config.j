// Replace RUN_ID before EVERY game session (safe [A-Za-z0-9][A-Za-z0-9_.-]{0,79}).
// Build --run-id does NOT rewrite imported source. Keep both IDs equal.
library LabConfig
    globals
        constant string RM_RUN_ID = "UNCONFIGURED"
        constant string RM_LOG_FILE = "Logs\\RM28-" + RM_RUN_ID + ".txt"
        // all, lifecycle, motion, contact, environment, load, or one CASE ID.
        constant string RM_SELECT = "all"
        constant string RM_MODEL = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
        // Verified from recovered declarations/object members; never placeholder IDs.
        constant integer RM_UNIT = 'ntrg'
        constant integer RM_ITEM = 'I001'
        constant integer RM_TREE = 'LTlt'
    endglobals
endlibrary
