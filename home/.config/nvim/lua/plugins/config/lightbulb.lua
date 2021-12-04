local lightbulb = require("nvim-lightbulb")

lightbulb.get_status_text()
lightbulb.update_lightbulb({
    status_text = {
        enabled = true,
        text = "💡",
        text_unavailble = "",
    }
})
