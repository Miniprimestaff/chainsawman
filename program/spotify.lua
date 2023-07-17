local aukit = require("aukit")
local austream = shell.resolveProgram("austream")
local term = require("term")
local window = require("window")

-- Téléchargement du fichier de la liste de lecture
local playlistURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlist.json"
local response = http.get(playlistURL)
if response then
  local playlistData = response.readAll()
  response.close()

  -- Parsing du fichier JSON de la liste de lecture
  local success, playlist = pcall(textutils.unserializeJSON, playlistData)
  if success and type(playlist) == "table" then
    local w, h = term.getSize()
    local enth = h - 11
    local boxwin = window.create(term.current(), 2, 4, w - 2, h - 9)
    local entrywin = window.create(boxwin, 2, 2, w - 4, enth)

    term.setBackgroundColor(colors.black)
    term.clear()
    boxwin.setBackgroundColor(colors.gray)
    boxwin.clear()
    entrywin.setBackgroundColor(colors.gray)
    entrywin.clear()

    local selection, scroll = 1, 1
    local entries = playlist
    local config = {
      backgroundcolor = colors.black,
      boxbackground = colors.gray,
      boxcolor = colors.white,
      textcolor = colors.white,
      selectcolor = colors.lightGray,
      selecttext = colors.black,
      titlecolor = colors.white,
      title = "Sélectionnez une musique"
    }

    if config.defaultentry then
      for i = 1, #entries do
        if entries[i].name == config.defaultentry then
          selection = i
          break
        end
      end
      if config.timeout == 0 and boot(entries[selection]) then
        return
      end
    end

    local function drawEntries()
      entrywin.setVisible(false)
      entrywin.setBackgroundColor(config.boxbackground or config.backgroundcolor)
      entrywin.clear()
      for i = scroll, scroll + enth - 1 do
        local e = entries[i]
        if not e then
          break
        end
        entrywin.setCursorPos(2, i - scroll + 1)
        if i == selection then
          entrywin.setBackgroundColor(config.selectcolor)
          entrywin.setTextColor(config.selecttext)
        else
          entrywin.setBackgroundColor(config.boxbackground or config.backgroundcolor)
          entrywin.setTextColor(config.textcolor)
        end
        entrywin.clearLine()
        entrywin.write(#e.name > w - 6 and e.name:sub(1, w - 9) .. "..." or e.name)
        if i == selection and config.timeout then
          local s = tostring(config.timeout)
          entrywin.setCursorPos(w - 4 - #s, i - scroll + 1)
          entrywin.write(s)
          entrywin.setCursorPos(2, i - scroll + 1)
        end
      end
      entrywin.setVisible(true)
      term.setCursorPos(5, h - 5)
      term.clearLine()
      term.setTextColor(config.titlecolor)
      term.write(entries[selection].description or "")
    end

    local function drawScreen()
      local bbg, bfg = hex(select(2, math.frexp(config.boxbackground or config.backgroundcolor))), hex(select(2, math.frexp(config.boxcolor or config.textcolor)))
      boxwin.setTextColor(config.boxcolor or config.textcolor)
      boxwin.setCursorPos(1, 1)
      boxwin.write("\x9C" .. ("\x8C"):rep(w - 4))
      boxwin.blit("\x93", bbg, bfg)
      for y = 2, h - 10 do
        boxwin.setCursorPos(1, y)
        boxwin.blit("\x95", bfg, bbg)
        boxwin.setCursorPos(w - 2, y)
        boxwin.blit("\x95", bbg, bfg)
      end
      boxwin.setCursorPos(1, h - 9)
      boxwin.setBackgroundColor(config.boxbackground or config.backgroundcolor)
      boxwin.setTextColor(config.boxcolor or config.textcolor)
      boxwin.write("\x8D" .. ("\x8C"):rep(w - 4) .. "\x8E")

      term.setCursorPos((w - #config.title) / 2, 2)
      term.setTextColor(config.titlecolor or config.textcolor)
      term.write(config.title)
      term.setCursorPos(5, h - 3)
      term.write("Utilisez les touches \x18 et \x19 pour sélectionner.")
      term.setCursorPos(5, h - 2)
      term.write("Appuyez sur Entrée pour démarrer la musique sélectionnée.")
      term.setCursorPos(5, h - 1)
      term.write("'c' pour shell, 'e' pour éditer.")

      drawEntries()
    end

    drawScreen()

    while true do
      local event, param1, param2, param3 = os.pullEvent()
      if event == "mouse_scroll" then
        handleScrollEvent(param1)
      elseif event == "key" then
        if param1 == keys.up then
          handleScrollEvent(-1)
        elseif param1 == keys.down then
          handleScrollEvent(1)
        elseif param1 == keys.enter then
          local selectedMusic = entries[selection]
          local selectedTitle = selectedMusic.name
          local selectedURL = selectedMusic.link
          -- Lecture de la musique sélectionnée
          playMusic(selectedTitle, selectedURL)
        end
      end
      drawScreen()
    end
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
