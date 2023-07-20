local aukitPath = "aukit.lua"
local austreamPath = "austream.lua"
local upgradePath = "upgrade"

-- Fonction pour vérifier si un fichier existe
local function fileExists(path)
  return fs.exists(path) and not fs.isDir(path)
end

-- Vérification et téléchargement des fichiers AUKit et AUStream
if not fileExists(aukitPath) then
  shell.run("wget", "https://github.com/MCJack123/AUKit/raw/master/aukit.lua", aukitPath)
end

if not fileExists(austreamPath) then
  shell.run("wget", "https://github.com/MCJack123/AUKit/raw/master/austream.lua", austreamPath)
end

-- Vérification et téléchargement du fichier "upgrade"
if not fileExists(upgradePath) then
  shell.run("pastebin", "get", "PvwtVW1S", upgradePath)
end

local playlistURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlist.json"
local darkPlaylistURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlistdark.json"

local function getPlaylistData(url)
  local response = http.get(url)
  if response then
    local playlistData = response.readAll()
    response.close()
    return playlistData
  end
  return nil
end

local playlistData = getPlaylistData(playlistURL)
local darkPlaylistData = getPlaylistData(darkPlaylistURL)

if playlistData and darkPlaylistData then
  local success, playlist = pcall(textutils.unserializeJSON, playlistData)
  local successDark, playlistDark = pcall(textutils.unserializeJSON, darkPlaylistData)

  if success and type(playlist) == "table" and successDark and type(playlistDark) == "table" then
    local musicList = {}
    for _, entry in ipairs(playlist) do
      table.insert(musicList, entry.title)
    end

    local function playMusic(title, musicURL)
      shell.run(austreamPath, musicURL)
    end

    local function displayMusicMenu(isDarkMode)
      local itemsPerPage = 6
      local currentPage = 1
      local totalOptions = #musicList
      local totalPages = math.ceil(totalOptions / itemsPerPage)
      local selectedIndex = 1

      term.clear()
      term.setCursorPos(1, 1)

      if not isDarkMode then
        -- Afficher le texte "Spotifo" et "by Dartsgame" en vert sans boot menu
        term.setTextColor(colors.green)
        term.write("Spotifo\n")
        term.setTextColor(colors.gray)
        term.write("by Dartsgame\n")
        sleep(3)
      else
        -- Afficher le texte en rouge pour le mode alternatif (easter egg)
        term.setTextColor(colors.red)
        term.write("Spotifo (Mode alternatif)\n")
        term.write("by Dartsgame (Version rouge)\n")
      end

      while true do
        -- Vider l'écran avant d'afficher le menu
        term.clear()
        term.setCursorPos(1, 3)

        local textColor = colors.green
        local selectionColor = colors.green

        if isDarkMode then
          textColor = colors.red
          selectionColor = colors.red
        end

        term.setTextColor(textColor)
        term.setCursorPos(1, 2)
        term.write(string.rep(string.char(143), term.getSize()))
        term.setCursorPos(1, 3)
        term.write(string.rep(" ", term.getSize()))
        term.setCursorPos((term.getSize() - 7) / 2 + 1, 3)
        term.write("Spotifo")
        term.setCursorPos(1, 4)
        term.write(string.rep(string.char(143), term.getSize()))

        local startIndex = (currentPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, totalOptions)

        for i = startIndex, endIndex do
          local optionIndex = i - startIndex + 1
          local option = musicList[i]

          if optionIndex == selectedIndex then
            term.setTextColor(selectionColor)
            option = option .. " "
          else
            term.setTextColor(textColor)
          end

          print(optionIndex, " [" .. option .. "]")
        end

        term.setTextColor(colors.white)
        local pageText = currentPage .. "/" .. totalPages
        local totalText = "Titres " .. totalOptions
        local headerText = "Spotifo  " .. pageText .. "  " .. totalText
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
          local selectedMusic = isDarkMode and playlistDark[selectedOption] or playlist[selectedOption]
          playMusic(selectedMusic.title, selectedMusic.link)
        end
      end
    end

    local function isKeyPressed()
      local event, key = os.pullEvent("key")
      return key ~= nil
    end

    local isDarkMode = isKeyPressed()
    if isDarkMode then
      musicList = {}
      for _, entry in ipairs(playlistDark) do
        table.insert(musicList, entry.title)
      end
    end

    displayMusicMenu(isDarkMode)
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
