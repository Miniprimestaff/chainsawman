local aukitPath = "aukit.lua"
local austreamPath = "austream.lua"
local upgradePath = "upgrade"

local function fileExists(path)
  return fs.exists(path) and not fs.isDir(path)
end

if not fileExists(aukitPath) then
  shell.run("wget", "https://github.com/MCJack123/AUKit/raw/master/aukit.lua", aukitPath)
end

if not fileExists(austreamPath) then
  shell.run("wget", "https://github.com/MCJack123/AUKit/raw/master/austream.lua", austreamPath)
end

if not fileExists(upgradePath) then
  shell.run("pastebin", "get", "PvwtVW1S", upgradePath)
end

local playlistFile = "playlist.json"
local playlistURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlist.json"
local response = http.get(playlistURL)
if response then
  local playlistData = response.readAll()
  response.close()

  local success, onlinePlaylist = pcall(textutils.unserializeJSON, playlistData)
  if success and type(onlinePlaylist) == "table" then
    local playlist = {}
    if fileExists(playlistFile) then
      local fileHandle = fs.open(playlistFile, "r")
      local playlistData = fileHandle.readAll()
      fileHandle.close()
      playlist = textutils.unserializeJSON(playlistData)
    else
      local fileHandle = fs.open(playlistFile, "w")
      fileHandle.write(textutils.serializeJSON(playlist))
      fileHandle.close()
    end

    for _, entry in ipairs(onlinePlaylist) do
      table.insert(playlist, entry)
    end

    local fileHandle = fs.open(playlistFile, "w")
    fileHandle.write(textutils.serializeJSON(playlist))
    fileHandle.close()

    local musicList = {}
    for _, entry in ipairs(playlist) do
      table.insert(musicList, entry.title)
    end

    local function playMusic(title, musicURL)
      shell.run(austreamPath, musicURL)
    end

    local function displayMusicMenu()
      local itemsPerPage = 6
      local currentPage = 1
      local totalOptions = #musicList
      local totalPages = math.ceil(totalOptions / itemsPerPage)
      local selectedIndex = 1

      term.clear()
      local screenWidth, screenHeight = term.getSize()
      local logoHeight = 5
      local logoText = "Spotifo"
      local byText = "by Dartsgame"
      local logoY = math.floor((screenHeight - logoHeight) / 2)
      local logoX = math.floor((screenWidth - #logoText) / 2)
      term.setTextColor(colors.green)
      term.setCursorPos(1, logoY)
      term.write(string.rep(string.char(143), screenWidth))
      term.setCursorPos(1, logoY + 1)
      term.write(string.rep(" ", screenWidth))
      term.setCursorPos(logoX, logoY + 2)
      term.write(logoText)
      term.setCursorPos((screenWidth - #byText) / 2 + 1, logoY + 3)
      term.write(byText)
      term.setCursorPos(1, logoY + 4)
      term.write(string.rep(string.char(143), screenWidth))
      sleep(2)

      while true do
        term.clear()
        term.setCursorPos(1, 3)

        term.setTextColor(colors.green)
        term.setCursorPos(1, 2)
        term.write(string.rep(string.char(143), term.getSize()))
        term.setCursorPos(1, 3)
        term.write(string.rep(" ", term.getSize()))
        term.setCursorPos((term.getSize() - #logoText) / 2 + 1, 3)
        term.write(logoText)
        term.setCursorPos(1, 4)
        term.write(string.rep(string.char(143), term.getSize()))

        local startIndex = (currentPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, totalOptions)

        for i = startIndex, endIndex do
          local optionIndex = i - startIndex + 1
          local option = musicList[i]

          if optionIndex == selectedIndex then
            term.setTextColor(colors.green)
            option = option .. " "
          else
            term.setTextColor(colors.gray)
          end

          print(optionIndex, " [" .. option .. "]")
        end

        term.setTextColor(colors.white)
        local pageText = currentPage .. "/" .. totalPages
        local totalText = "Titres " .. totalOptions
        local headerText = logoText .. "  " .. pageText .. "  " .. totalText
        local headerTextPos = (term.getSize() - #headerText) / 2 + 1
        term.setCursorPos(headerTextPos, 3)
        term.write(headerText)

        term.setCursorPos(1, itemsPerPage + 7)
        term.write(string.char(17))
        term.setCursorPos(term.getSize(), itemsPerPage + 7)
        term.write(string.char(16))

        local _, key = os.pullEvent("key")

        if key == keys.up then
          selectedIndex = selectedIndex - 1
          if selectedIndex < 1 then
            selectedIndex = endIndex - startIndex + 1
          end
        elseif key == keys.down then
          selectedIndex = selectedIndex + 1
          if selectedIndex > endIndex - startIndex + 1 then
            selectedIndex = 1
          end
        elseif key == keys.left and currentPage > 1 then
          currentPage = currentPage - 1
          selectedIndex = math.min(selectedIndex, endIndex - startIndex + 1)
        elseif key == keys.right and currentPage < totalPages then
          currentPage = currentPage + 1
          selectedIndex = math.min(selectedIndex, endIndex - startIndex + 1)
        elseif key == keys.enter then
          local selectedOption = startIndex + selectedIndex - 1
          local selectedMusic = playlist[selectedOption]
          playMusic(selectedMusic.title, selectedMusic.link)
        end
      end
    end

    displayMusicMenu()
  else
    print("Erreur de parsing du fichier de la liste de lecture en ligne.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture en ligne.")
end
