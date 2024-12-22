local vide = require("@pkg/vide")

local state = {}

state.lines = vide.source({}) :: vide.Source<{ string }>
state.inCommand = vide.source(false) :: vide.Source<boolean>
state.open = vide.source(false) :: vide.Source<boolean>

return state
