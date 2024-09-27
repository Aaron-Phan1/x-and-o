local game = {
    EMPTY = 0,
    X = "X",
    O = "O",
}

function game:new(o, difficulty, group)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.board = board or {

        {"tl", 1, w20, h40, w40, h20,0, nil},
        {"tm",2, w40,h40,w60,h20,0, nil},
        {"tr",3, w60,h40,w80,h20,0, nil},
        
        {"ml", 4, w20, h60, w40, h40,0, nil},
        {"mm",5, w40,h60,w60,h40,0, nil},
        {"mr",6, w60,h60,w80,h40,0, nil},
        
        {"bl", 7, w20, h80, w40, h60,0, nil},
        {"bm",8, w40,h80,w60,h60,0, nil},
        {"br",9, w60,h80,w80,h60,0, nil}
    }
    self.difficulty = difficulty
    self.sceneGroup = group
    self.moveHistory = moveHistory or {}
    self.result = nil

    return o
end

function game:execute_command(command)
    self.board = command:execute(self.board, self.sceneGroup)
    table.insert(self.moveHistory, command)
end

function game:undo()
    local command = table.remove(self.moveHistory)
    self.board = command:undo(self.board)
end

function game:get_board()
    return self.board
end

return game