dofile('/home/leonb/torch/packages/help/init.lua')

function filterIdentity(x)
   return x
end

function filterIdentityLink(link, text)
   return '<a href="' .. link .. '">' .. text .. '</a>'
end

filterTitle = filterIdentity
filterNavLine = filterIdentity
filterContents = filterIdentity
filterSubSections = filterIdentity
filterLastModified = filterIdentity
filterPreviousSection = filterIdentityLink
filterNextSection = filterIdentityLink
filterUpSection = filterIdentityLink

help = help.__internal__

function string.gsubx(s, pattern, repl)
   return string.gsub(s, pattern, function() return repl end)
end

function isExtendedFormat(fileName)
   local f = io.open(fileName, 'r')
   if not f then
      error('cannot open file <' .. fileName .. '> in read mode')
   end
   local line = f:read('*line')
   f:close()
   if string.match(line, '^<extended>') then      
      return true
   end
   return false
end

function computeAnchorLocations(anchorLocations, reverseAnchors, path, fileName, section, anchors, extended)
   -- note: we do not use path here...
   fileName = string.gsub(fileName, '%.hlp$', '')

   if anchors then
      for k,v in pairs(anchors) do
         reverseAnchors[v] = k
      end
   end
   
   local anchorName = reverseAnchors[section]
   if anchorName then
      anchorLocations[anchorName] = fileName 
   end
   if section.sections then   
      for i=1,#section.sections do
         -- la seule difference avec l'expand est ici
         if extended then
            computeAnchorLocations(anchorLocations, reverseAnchors, path, fileName, section.sections[i], extended)
         else
            computeAnchorLocations(anchorLocations, reverseAnchors, path, fileName .. '-' .. i, section.sections[i])
         end
      end
   end
end

function printSection(path, fileName, templateFile, depth, lastModified, section, htmlPath, outputPath, extendedFormat,
                        linkUp, nameUp, linkPrevious, namePrevious, linkNext, nameNext)

   linkUp = linkUp or ""
   nameUp = nameUp or ""
   linkPrevious = linkPrevious or ""
   namePrevious = namePrevious or ""
   linkNext = linkNext or ""
   nameNext = nameNext or ""

   fileName = string.gsub(fileName, '%.hlp$', '')

   -- hook for links: help.linkHTML()
   -- note: could remove the 'links' returned by help.renderTextHTML()
   function help.linkHTML(link, linkText)
      if string.match(link, '^#.+') then
         if anchorLocations[link] then
            return '<a href="' .. anchorLocations[link] .. '.html' .. link .. '">' .. linkText .. '</a>'
         else
            print('WARNING: could not find link <' .. link .. '>')
            return '<a href="' .. link .. '">' .. linkText .. '</a>'
         end
      else -- external file [TODO] or web
         if string.match(link, '%.hlp$') then -- external link, no anchor
            -- just check it to be sure
            local f = io.open(path .. '/' .. link, 'r')
            if f then
               f:close()
            else
               print('WARNING: could not find external link <' .. link .. '>')
            end
            return '<a href="' .. string.gsub(link, '%.hlp$', '.html') .. '">' .. linkText .. '</a>'
         elseif string.match(link, '%.hlp#.*$') then
            -- parsing external file if necessary
            local externalFile = string.match(link, '(.*%.hlp)')
            local externalAnchor = string.match(link, '(#.*)')
            if not externalFiles then
               externalFiles = {}
            end
            if not externalFiles[externalFile] then
               local f = io.open(path .. '/' .. externalFile, 'r')
               if f then
                  f:close()
--                  print('# Parsing ' .. externalFile)
                  externalFiles[externalFile] = {}
                  local externalSections, externalAnchors = help.buildTree(path, externalFile)
                  externalFiles[externalFile].reverseAnchors = {}
                  externalFiles[externalFile].anchorLocations = {}
                  computeAnchorLocations(externalFiles[externalFile].anchorLocations, externalFiles[externalFile].reverseAnchors, path, externalFile, externalSections, externalAnchors, isExtendedFormat(path .. '/' .. externalFile, 'r'))
               end
            end

            -- ok, so now we can check your anchor man'
            if externalFiles[externalFile] and externalFiles[externalFile].anchorLocations[externalAnchor] then
               return '<a href="' .. externalFiles[externalFile].anchorLocations[externalAnchor] .. '.html' .. externalAnchor .. '">' .. linkText .. '</a>'
            else
               print('WARNING: could not find external link <' .. link .. '>')
               return '<a href="' .. link .. '">' .. linkText .. '</a>'
            end

--            return '<a href="' .. link .. '">' .. linkText .. '</a>'
         else
--            print('EXTERNAL REF TO <' .. link .. '>')
            return '<a href="' .. link .. '">' .. linkText .. '</a>'
         end
      end
   end
   
   local _,_fileName = help.splitPath(fileName)
   local template
   if depth == 0 or not extendedFormat then
      local tf = io.open(templateFile, 'r')
      if not tf then
         error('cannot open template file <' .. templateFile .. '> for reading')
      end
      template = tf:read('*all')
      tf:close()

      local rtts = help.renderTextHTML(section.name)
      rtts = string.gsub(rtts, "%b<>", "")
      template = string.gsubx(template, '%%TITLE%%', filterTitle(rtts))
   else
      local f = io.open(outputPath .. '/' .. _fileName .. '.html', 'r')
      template = f:read('*all')
   end

   local contents = ""
   local rtt = help.renderTextHTML(section.name)
   local rt = help.renderTextHTML(section.contents)
   local anchorName = reverseAnchors[section]
   if anchorName then
      contents = contents .. '<a name="' .. string.match(anchorName, '^#(.*)') .. '"></a>\n'
   end

   if depth == 0 or not extendedFormat then
      local htmlPathToHere
      if #htmlPath > 0 then
         htmlPathToHere = htmlPath .. '&nbsp; > &nbsp; <b>' .. rtt .. '</b>'
      else
         htmlPathToHere = htmlPath .. '<b>' .. rtt .. '</b>'
      end
      template = string.gsubx(template, '%%NAVLINE%%', filterNavLine(htmlPathToHere))
   else
      contents = contents .. '<h' .. depth .. '>' .. rtt .. '</h' ..depth .. '>\n'
   end
   contents = contents .. rt
   template = string.gsubx(template, '%%CONTENTS%%', filterContents(contents) .. '%CONTENTS%')

   local f = io.open(outputPath .. '/' .. _fileName .. '.html', 'w')
   if not f then
      error('cannot open file <' .. outputPath .. '/' .. _fileName .. '.html' .. '> for writing')
   end

   local subSectionsTxt = ""
   if not extendedFormat then
      if section.sections then
         subSectionsTxt = subSectionsTxt .. '<ol>\n'
         for i,subSection in ipairs(section.sections) do
            subSectionsTxt = subSectionsTxt .. '<li><a href="' .. fileName .. '-' .. i .. '.html">' .. help.renderTextHTML(subSection.name) .. '</a></li>\n'
         end
         subSectionsTxt = subSectionsTxt .. '</ol>\n'
      end
   end
   template = string.gsubx(template, '%%SUBSECTIONS%%', filterSubSections(subSectionsTxt))

   template = string.gsubx(template, '%%PREVIOUSSECTION%%', filterPreviousSection(linkPrevious, namePrevious))
   template = string.gsubx(template, '%%NEXTSECTION%%', filterNextSection(linkNext, nameNext))
   template = string.gsubx(template, '%%UPSECTION%%', filterUpSection(linkUp, nameUp))

   f:write(template)
   f:close()

   if section.sections then   
--      print('n = ' .. #sections.sections)
      for i=1,#section.sections do
--         print('_____', section.sections[i])
--         print('___' .. section.sections[i].name)
         local fp, fn, np, nn
         if i > 1 then
            fp = fileName .. '-' .. i-1 .. '.html'
            np = help.renderTextHTML(section.sections[i-1].name)
         end
         if i < #section.sections then
            fn = fileName .. '-' .. i+1 .. '.html'
            nn = help.renderTextHTML(section.sections[i+1].name)
         end
         local htmlPathSub
         if #htmlPath > 0 then
            htmlPathSub = htmlPath .. '&nbsp; > &nbsp; <a href="' .. fileName ..  '.html">' .. rtt .. '</a>'
         else
            htmlPathSub = htmlPath .. '<a href="' .. fileName ..  '.html">' .. rtt .. '</a>'
         end
         if extendedFormat then
            printSection(path, fileName, templateFile, depth+1, lastModified, section.sections[i], htmlPathSub, outputPath, extendedFormat)
         else
            printSection(path, fileName .. '-' .. i, templateFile, depth+1, lastModified, section.sections[i], htmlPathSub, outputPath, nil, fileName .. '.html', help.renderTextHTML(section.name), fp, np, fn, nn)
         end
      end
   end

   if depth == 0 or not extendedFormat then
      local f = io.open(outputPath .. '/' .. _fileName .. '.html', 'r')
      template = f:read('*all')
      f:close()

      template = string.gsubx(template, '%%CONTENTS%%', '')
      template = string.gsubx(template, '%%LASTMODIFIED%%', filterLastModified(lastModified))

      f = io.open(outputPath .. '/' .. _fileName .. '.html', 'w')
      f:write(template)
      f:close()
   end
end

if not arg or #arg < 1 or #arg > 6 then
   print('hlp to html converter')
   print()
   print('usage:')
   print('  lua hlp2html.lua <hlp file> <template html file> [html nav] [output path] [last modified] [filters]')
   print()
   print('  <...> is mandatory')
   print('  [...] is optional')
   print()
   print(' hlp file: the hlp-format file')
   print(' template html file: self speaking, no?')
   print(' html nav: some html code for the root in navigation bar [default: nil]')
   print(' output path: path where will be written the output file [default: .]')
   print(' last modified: file used to get time stamp')
   print(' filters: some lua code containing filters')
   print()
   return
end

-- note: the paths are all RELATIVE to the path of arg[1]
if not string.match(arg[1], '%.hlp$') then
   error('Please provide a .hlp file!')
end

if not arg[2] then
   error('Please provide a template file!')
end

local htmlPath = arg[3] or ''
local outputPath = arg[4] or '.'


local lastModified = ""
-- if arg[5] then
--    require('posix')
--    print(arg[5])
--    lastModified = posix.ctime(posix.stat(arg[5]).mtime)
-- else
-- end

if arg[6] then
   dofile(arg[6])
end

local path, fileName = help.splitPath(arg[1])
local sections, anchors = help.buildTree(path, fileName)
reverseAnchors = {}
anchorLocations = {}
computeAnchorLocations(anchorLocations, reverseAnchors, path, fileName, sections, anchors)
printSection(path, fileName, arg[2], 0, lastModified, sections, htmlPath, outputPath, isExtendedFormat(path .. '/' .. fileName))
