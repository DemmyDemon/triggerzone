Config = {
    Editor = {
        BoostFactor = 10.0,
        Sensitivity = 5.0,
        DeleteProximity = 0.2,
        HeightAdjustInterval = 0.1,
        MinHeight = 0.2,
        DefaultHeight = 2.0,
        Speed = {
            Min = 5,
            Start = 10,
            Max = 100,
            Interval = 5,
        },
        EnableControls = {245, 249}, -- What controls are enabled while in the editor? 245 is INPUT_MP_TEXT_CHAT_ALL, and 249  is INPUT_PUSH_TO_TALK
        Keys = {
            Boost = 21, -- INPUT_SPRINT, Left Shift
            SlowDown = 44, -- INPUT_COVER, Q
            SpeedUp = 38, -- INPUT_PICKUP, E
            Insert = 24, -- INPUT_ATTACK, left click
            Delete = 25, -- INPUT_AIM, right click,
            Forward = 32, -- INPUT_MOVE_UP_ONLY, W
            Back = 33, -- INPUT_MOVE_DOWN_ONLY, S
            Left = 34, -- 	INPUT_MOVE_LEFT_ONLY, A
            Right = 35, -- 	INPUT_MOVE_RIGHT_ONLY, D
            Focus = 22, -- INPUT_JUMP, Space
            Modifier = 36, -- INPUT_DUCK, Ctrl
            Increase = 17, -- INPUT_SELECT_NEXT_WEAPON, Scroll up
            Decrease = 16, -- INPUT_SELECT_PREV_WEAPON, Scroll down
        },
    },
}
