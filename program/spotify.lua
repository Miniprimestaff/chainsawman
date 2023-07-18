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

      -- Vérification de la présence d'un moniteur
      local hasMonitor = peripheral.isPresent("monitor")
      local monitor

      if hasMonitor then
        monitor = peripheral.find("monitor")
        monitor.clear()
        monitor.setCursorPos(1, 3)
        monitor.setTextColor(colors.green)
        monitor.write(string.rep(" ", monitor.getSize()))
        monitor.setCursorPos((monitor.getSize() - #logoText) / 2 + 1, 3)
        monitor.write(logoText)
        monitor.setTextColor(colors.white)
      end

      term.clear()
      term.setCursorPos(1, 3)
      term.setTextColor(colors.green)
      term.write(string.rep(" ", term.getSize()))
      term.setCursorPos((term.getSize() - #logoText) / 2 + 1, 3)
      term.write(logoText)
      term.setTextColor(colors.white)

      local function drawMenu()
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
          if hasMonitor then
            monitor.setTextColor(colors.gray)
            monitor.setCursorPos(1, i - startIndex + 3)
            monitor.write(optionIndex .. " [" .. option .. "]")
          end
        end
      end

      local function drawHeader()
        term.setCursorPos(1, 2)
        term.setTextColor(colors.green)
        term.write(string.rep(" ", term.getSize()))
        term.setCursorPos((term.getSize() - #logoText) / 2 + 1, 2)
        term.write(logoText)
        term.setTextColor(colors.white)

        if hasMonitor then
          monitor.setCursorPos(1, 2)
          monitor.setTextColor(colors.green)
          monitor.write(string.rep(" ", monitor.getSize()))
          monitor.setCursorPos((monitor.getSize() - #logoText) / 2 + 1, 2)
          monitor.write(logoText)
          monitor.setTextColor(colors.white)
        end
      end

      drawMenu()
      drawHeader()

      local function clearScreen()
        term.clear()
        term.setCursorPos(1, 1)
        if hasMonitor then
          monitor.clear()
          monitor.setCursorPos(1, 1)
        end
      end

      while true do
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

        clearScreen()
        drawMenu()
        drawHeader()
      end
    end

    if peripheral.isPresent("monitor") then
      local monitor = peripheral.find("monitor")
      monitor.setTextScale(1)
      monitor.setTextColor(colors.white)
      monitor.setBackgroundColor(colors.black)
      monitor.clear()
      displayMusicMenu()
    else
      term.setTextColor(colors.white)
      displayMusicMenu()
    end
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
