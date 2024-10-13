clearListener()

try (DestroyDialog imp_battleraper) catch()

rollout imp_battleraper "Battle Raper" (
	button btn1 "Import" width:120 height:30
	checkbox chk1 "Clear Scene" checked:true
	spinner spn1 "Scale" range:[-999999999.0, 999999999.0, 3.93701] type:#float scale:0.01 align:#left
	label lbl1 ""
	label lbl2 "Written By mariokart64n"
	struct _materials (
		diffuse=#(),
		ambient=#(),
		specular=#(),
		opacity=#(),
		power=#(),
		maps=#()
		)

	struct _textures (
		name=#(),
		size=#(),
		offset=#()
		)

	struct _geometry (
		position=#(),
		colour=#(),
		normal=#(),
		tangent=#(),
		texture=#(),
		weight=#(),
		boneid=#(),
		face=#(),
		matid=#(),
		mat=_materials()
		)

	-- Local variables within the rollout
	local f
	local g = _geometry()
	local mscale = (1.0 / 2.54) * 10
	local cnt = 0
	local t = _textures()

	-- Local Functions

	-- Function to write textures to disk
	fn writeTextures fpath = (
		makeDir (fpath + "\\textures")
		for i = 1 to t.name.count do (
			local s = fopen (fpath + "\\textures\\" + t.name[i]) "wb"
			fseek f t.offset[i] #seek_set
			for x = 1 to t.size[i] do (
				writebyte s (readbyte f #unsigned) #unsigned
				)
			fclose s
			)
		)

	-- Convert Right-Handed to Left-Handed coordinates
	fn RH2LH corrd = (
		[corrd.x, -corrd.z, corrd.y]
		)

	-- Function to build an object (mesh)
	fn buildObj meshname = (
		if g.position.count > 0 then (
			local msh = mesh vertices:g.position faces:g.face materialIDs:g.matid
			msh.numTVerts = g.texture.count
			msh.displayByLayer = false
			msh.backfacecull = on
			msh.wirecolor = random (color 0 0 0) (color 255 255 255)
			buildTVFaces msh
			msh.name = meshname

			-- Assign texture vertices and faces
			for j = 1 to g.texture.count do setTVert msh j g.texture[j]
			for j = 1 to g.face.count do setTVFace msh j g.face[j]

			-- Assign materials
			if g.mat.power.count > 1 then (
				local mat = Multimaterial numsubs:g.mat.power.count
				for j = 1 to g.mat.power.count do (
					mat.materialList[j] = StandardMaterial()
					mat.materialList[j].adTextureLock = off
					mat.materialList[j].adLock = off

					mat.materialList[j].ambient = g.mat.diffuse[j]
					mat.materialList[j].Diffuse = g.mat.opacity[j]
					mat.materialList[j].Specular = g.mat.ambient[j]
					mat.materialList[j].specularLevel = g.mat.power[j]
					mat.materialList[j].glossiness = 10
					mat.materialList[j].opacity = 100

					if g.mat.maps[j][1] != "" do (
						mat.materialList[j].diffuseMap = Bitmaptexture fileName:g.mat.maps[j][1]
						)
					if g.mat.maps[j][2] != "" do (
						mat.materialList[j].reflectionMap = Bitmaptexture fileName:g.mat.maps[j][2]
						)
					)
				)
			else (
				local mat = Standardmaterial()
				mat.ambient = g.mat.diffuse[1]
				mat.Diffuse = g.mat.opacity[1]
				mat.Specular = g.mat.ambient[1]
				mat.specularLevel = g.mat.power[1]
				mat.glossiness = 10
				mat.opacity = 100

				if g.mat.maps[1][1] != "" do (
					mat.diffuseMap = Bitmaptexture fileName:g.mat.maps[1][1]
					)
				if g.mat.maps[1][2] != "" do (
					mat.reflectionMap = Bitmaptexture fileName:g.mat.maps[1][2]
					)
				)
			msh.material = mat
			return msh
			)
		else (
			print "Nothing built"
			return undefined
			)
		)

	-- Function to generate faces
	fn genFaces count matid = (
		for i = 1 to count do (
			append g.face [(0 + cnt), (2 + cnt), (1 + cnt)]
			append g.matid matid
			cnt += 3
			)
		)

	-- Function to get color from file
	fn getColour = (
		local c = [0, 0, 0, 0]
		c[1] = readfloat f
		c[2] = readfloat f
		c[3] = readfloat f
		c[4] = readfloat f
		-- Optionally apply opacity to RGB
		-- c[1] *= c[4]
		-- c[2] *= c[4]
		-- c[3] *= c[4]
		c[1] *= 255.0
		c[2] *= 255.0
		c[3] *= 255.0
		return color c[1] c[2] c[3] c[4]
		)

	-- Function to get material data
	fn getMat offset textures = (
		local pos = ftell f
		fseek f offset #seek_set
		append g.mat.diffuse (getColour())
		append g.mat.ambient (getColour())
		append g.mat.specular (getColour())
		append g.mat.opacity (getColour())
		append g.mat.power (readfloat f)
		append g.mat.maps textures
		fseek f pos #seek_set
		)

	-- Function to read fixed-length strings
	fn ReadFixedString bstream fixedLen = (
		local str = ""
		for i = 1 to fixedLen do (
			str += bit.intAsChar (ReadByte bstream #unsigned)
			)
		return str
		)

	-- Function to read color files (if needed)
	fn readXCfile = (
		local c1 = readlong f #unsigned
		local c2 = readlong f #unsigned
		local c3 = readlong f #unsigned
		local c4 = readlong f #unsigned
		if c2 != 0 do (
			for i = 1 to c2 do (
				local u1 = readlong f #unsigned
				local u2 = readfloat f
				local u3 = readfloat f
				local u4 = readfloat f
				local u5 = readfloat f
				local u6 = readfloat f
				local u7 = readfloat f -- 0
				local u8 = readfloat f -- 0
				local u9 = readfloat f -- 1.0
				local uA = readfloat f -- 0.0
				local uB = readfloat f
				local d = dummy position:[u2, u5, u6] boxsize:[0.2, 0.2, 0.2]
				)
			)
		)

	-- Function to read XM files
	fn readXMfile = (
		ReadFixedString f 64
		local unk = readlong f #unsigned
		local meshcount = readlong f #unsigned
		format "Object Count: %\n" meshcount
		if unk != 0 do (format "New Count: %\n" unk)
		for i = 1 to meshcount do (
			g = _geometry()
			cnt = 1
			local objName = ReadFixedString f 64
			ReadFixedString f 64 -- material name?
			for i = 1 to 0x0100 collect (readbyte f #unsigned) -- Skipping some data
			readlong f #unsigned -- Skipping some data
			local sunMesh_count = readlong f #unsigned -- element count
			readlong f #unsigned -- Skipping some data
			readlong f #unsigned -- Skipping some data
			local check = readlong f #unsigned -- try to determine version number
			readlong f #unsigned -- Skipping some data
			readlong f #unsigned -- Skipping some data
			readlong f #unsigned -- Skipping some data
			if check != 0 and check != 1 do (
				fseek f -0x10 #seek_cur
				)

			local p01 = readfloat f -- min x
			local p02 = readfloat f -- min y
			local p03 = readfloat f -- min z

			local p04 = readfloat f -- max x
			local p05 = readfloat f -- max y
			local p06 = readfloat f -- max z

			local p07 = readfloat f -- scale x
			local p08 = readfloat f -- scale y
			local p09 = readfloat f -- scale z

			local p10 = readfloat f -- rotation x
			local p11 = readfloat f -- rotation y
			local p12 = readfloat f -- rotation z
			local p13 = readfloat f -- rotation w
			local p14 = readfloat f -- additional rotation or scaling

			-- Reading transformation matrix (ignored in this context)
			for x = 1 to 4 do (
				local m00 = readfloat f
				local m01 = readfloat f
				local m02 = readfloat f
				local m03 = readfloat f
				local m04 = readfloat f
				local m05 = readfloat f
				local m06 = readfloat f
				local m07 = readfloat f
				local m08 = readfloat f
				local m09 = readfloat f
				local m10 = readfloat f
				local m11 = readfloat f
				local m12 = readfloat f
				local m13 = readfloat f
				local m14 = readfloat f
				local m15 = readfloat f
				)

			local posFinal = RH2LH([ (p01 + p04)/2, (p02 + p05)/2, -((p03 + p06)/2) ]) * mscale
			local objs = #()

			for y = 1 to sunMesh_count do (
				if y > 1 do (
					objName += "_" + (y as string)
					)
				local matName = ReadFixedString f 64
				local texName1 = ReadFixedString f 64
				local texName2 = ReadFixedString f 64
				local count = readlong f #unsigned
				local count2 = readlong f #unsigned
				if count2 != 0 do (
					format "New Data found: %\n" count2
					)
				local tex_size1 = readlong f #unsigned -- size, texture1
				local tex_size2 = readlong f #unsigned -- size, texture2
				local tex_offset1 = readlong f #unsigned -- offset, texture1
				local tex_offset2 = readlong f #unsigned -- offset, texture2

				local textureOffset = readlong f #unsigned
				getMat textureOffset #(texName1, texName2)

				if tex_size1 != 0 and (findItem t.name texName1) == 0 do (
					append t.name texName1
					append t.size tex_size1
					append t.offset tex_offset1
					)
				if tex_size2 != 0 and (findItem t.name texName2) == 0 do (
					append t.name texName2
					append t.size tex_size2
					append t.offset tex_offset2
					)

				-- Reading vertex data
				for x = 1 to (count * 3) do (
					local vx = readfloat f
					local vy = readfloat f
					local vz = readfloat f
					local nx = readfloat f
					local ny = readfloat f
					local nz = readfloat f
					local tu = readfloat f
					local tv = readfloat f
					append g.position (RH2LH ([vx, vy, vz] * mscale))
					append g.texture [tu, -tv, 0]
					)

				genFaces count y
				append objs (buildObj objName)
				)

			if objs.count > 0 do (
				select objs
				posFinal = posFinal - $.center
				objs.position = posFinal
				-- Optional scaling
				-- objs.scale = [p07, p08, p09]
				-- for z = 1 to objs.count do (
				--     objs[z].position = posFinal
				-- )
				)
			)
		)

	-- Function to read the file
	fn read fsource = (
		if (fsource != undefined) and (doesFileExist fsource) then (
			f = fopen fsource "rb"
			undo off (
				with redraw off (
					readXMfile()
					writeTextures (getFilenamePath fsource)
					)
				)
			format "Last Read @ 0x%\n" ((bit.intAsHex (ftell f)) as string)
			fclose f
			)
		else (
			print "Aborted."
			)
		)

	-- Event handler for dialog open (if needed)
	on imp_battleraper open do (
		-- You can add initialization code here if necessary
		)

	-- Event handler for Import button press
	on btn1 pressed do (
		gc() -- Garbage collect to free memory
		f = undefined
		g = _geometry()
		mscale = spn1.value
		cnt = 0
		t = _textures()
		local selectedFile = GetOpenFileName caption:"Select a File" types:"xm (*.*)|*.xm|xa (*.*)|*.xa|All files (*.*)|*.*|"
		if chk1.checked do delete objects
		read selectedFile
		)
	)

-- Create and display the dialog
CreateDialog imp_battleraper

-- Optionally, read a default file on startup
-- imp_battleraper.read (
-- 	"E:\\BackUp\\TREKSTOR\\_3DMODELS\\Ripped\\Illusion3DModels\\BattleRaper\\Fa Taolee\\A03_01.xm"
-- 	)
