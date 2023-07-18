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

      while true do
        term.clear()
        term.setCursorPos(1, 3)

        term.setTextColor(colors.green)
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
            term.setTextColor(colors.green)
            option = option .. " "
          else
            term.setTextColor(colors.gray)
          end

          print(optionIndex, " [" .. option .. "]")
        end

        term.setTextColor(colors.white)

        local pageText = "Page " .. currentPage .. "/" .. totalPages
        local pageTextPos
        if pocket then
          -- Calcul de la position du texte de la page pour les ordinateurs de poche
          pageTextPos = (term.getSize() - #pageText) / 2 + 1
          term.setCursorPos(pageTextPos, term.getSize())
        else
          -- Calcul de la position du texte de la page pour les autres ordinateurs
          pageTextPos = (term.getSize() - #pageText) / 2 + 1
          term.setCursorPos(pageTextPos, itemsPerPage + 7)
        end

        term.write(pageText)

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
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
