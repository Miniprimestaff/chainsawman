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

local aukit = require("aukit")
local austream = shell.resolveProgram("austream")

local playlistURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlist.json"
local response = http.get(playlistURL)
if response then
  local playlistData = response.readAll()
  response.close()

  local success, playlist = pcall(textutils.unserializeJSON, playlistData)
  if success and type(playlist) == "table" then
    local musicList = {}
    for _, entry in ipairs(playlist) do
      table.insert(musicList, entry.title)
    end

    local function playMusic(title, musicURL)
      shell.run(austream, musicURL)
    end

    local function displayMusicMenu()
      local itemsPerPage = 6
      local currentPage = 1
      local totalOptions = #musicList
      local totalPages = math.ceil(totalOptions / itemsPerPage)
      local selectedIndex = 1

      local secretCode = ""
      local easterEggMode = false

      -- Boot Menu
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
      sleep(2) -- Attente de 2 secondes

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
        local keyName = keys.getName(key)

        if keyName == "b" or keyName == "a" or keyName == "t" or keyName == "m" or keyName == "n" then
          -- Ajouter le caractère de la touche pressée à la chaîne secrète
          secretCode = secretCode .. keyName

          -- Vérifier si la chaîne secrète correspond au code caché (b-a-t-m-a-n)
          if secretCode == "batman" then
            easterEggMode = true
            -- Changer ici la couleur de fond en violet pour l'easter egg
            term.setBackgroundColor(colors.purple)
            term.clear()
            -- Charger la playlist alternative depuis le fichier "playlistdark.json"
            local playlistURLDark = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlistdark.json"
            local responseDark = http.get(playlistURLDark)
            if responseDark then
              local playlistDataDark = responseDark.readAll()
              responseDark.close()
              success, playlist = pcall(textutils.unserializeJSON, playlistDataDark)
              if success and type(playlist) == "table" then
                musicList = {}
                for _, entry in ipairs(playlist) do
                  table.insert(musicList, entry.title)
                end
              else
                print("Erreur de parsing du fichier de la liste de lecture alternative.")
                return
              end
            else
              print("Erreur lors du téléchargement du fichier de la liste de lecture alternative.")
              return
            end
            -- Réinitialiser la chaîne secrète après un court délai
            os.sleep(0.5)
            secretCode = ""
          end
        else
          secretCode = ""
        end

        if easterEggMode then
          -- Utiliser la playlist alternative pour le mode easter egg
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
        else
          -- Utiliser la playlist normale pour le mode normal
          if key == keys.up then
            selectedIndex = selectedIndex - 1
            if selectedIndex < 1 then
              selectedIndex = totalOptions
            end
          elseif key == keys.down then
            selectedIndex = selectedIndex + 1
            if selectedIndex > totalOptions then
              selectedIndex = 1
            end
          elseif key == keys.left then
            currentPage = currentPage - 1
            if currentPage < 1 then
              currentPage = totalPages
            end
            selectedIndex = math.min(selectedIndex, endIndex - startIndex + 1)
          elseif key == keys.right then
            currentPage = currentPage + 1
            if currentPage > totalPages then
              currentPage = 1
            end
            selectedIndex = math.min(selectedIndex, endIndex - startIndex + 1)
          elseif key == keys.enter then
            local selectedOption = startIndex + selectedIndex - 1
            local selectedMusic = playlist[selectedOption]
            playMusic(selectedMusic.title, selectedMusic.link)
          end
        end
      end
    end

    displayMusicMenu()
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
