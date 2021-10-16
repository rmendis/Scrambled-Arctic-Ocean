-- Arctic.lua
-- Author: blkbutterfly74
-- DateCreated: 31/8/2017 2:20:20 AM
-- Creates a huge map of the arctic circle 
-- based off Scrambled Greenland, Scrambled Antarctica and Scrambled North America map scripts
-- Thanks to Firaxis
-----------------------------------------------------------------------------

include "MapEnums"
include "MapUtilities"
include "MountainsCliffs"
include "RiversLakes"
include "FeatureGenerator"
include "TerrainGenerator"
include "NaturalWonderGenerator"
include "ResourceGenerator"
include "AssignStartingPlots"

local g_iW, g_iH;
local g_iFlags = {};
local g_continentsFrac = nil;
local g_iNumTotalLandTiles = 0;
local arctic = nil;

-- north pole
local g_CenterX = 49;
local g_CenterY = 52;

local g_iE = 185;		-- approx. distance to equator from north pole

-------------------------------------------------------------------------------
function GenerateMap()
	print("Generating Arctic Ocean Map");
	local pPlot;

	-- Set globals
	g_iW, g_iH = Map.GetGridSize();

	g_iFlags = TerrainBuilder.GetFractalFlags();
	local temperature = 0;
	
	plotTypes = GeneratePlotTypes();
	terrainTypes = GenerateTerrainTypesArctic(plotTypes, g_iW, g_iH, g_iFlags, false);

	for i = 0, (g_iW * g_iH) - 1, 1 do
		pPlot = Map.GetPlotByIndex(i);
		if (plotTypes[i] == g_PLOT_TYPE_HILLS) then
			terrainTypes[i] = terrainTypes[i] + 1;
		end
		TerrainBuilder.SetTerrainType(pPlot, terrainTypes[i]);
	end

	-- Temp
	AreaBuilder.Recalculate();
	local biggest_area = Areas.FindBiggestArea(false);
	print("After Adding Hills: ", biggest_area:GetPlotCount());

	-- Place lakes before rivers to allow them to act as sources for rivers
	AddLakes();

	-- River generation is affected by plot types, originating from highlands and preferring to traverse lowlands.
	AddRivers();

	AddFeatures();
	
	print("Adding cliffs");
	AddCliffs(plotTypes, terrainTypes);
	
	local args = {
		numberToPlace = GameInfo.Maps[Map.GetMapSize()].NumNaturalWonders,
	};

	local nwGen = NaturalWonderGenerator.Create(args);

	AreaBuilder.Recalculate();
	TerrainBuilder.AnalyzeChokepoints();
	TerrainBuilder.StampContinents();
	
	resourcesConfig = MapConfiguration.GetValue("resources");
	local args = {
		resources = resourcesConfig,
		iWaterLux = 4,
	}
	local resGen = ResourceGenerator.Create(args);

	print("Creating start plot database.");
	-- START_MIN_Y and START_MAX_Y is the percent of the map ignored for major civs' starting positions.
	local startConfig = MapConfiguration.GetValue("start");-- Get the start config
	local args = {
		MIN_MAJOR_CIV_FERTILITY = 175,
		MIN_MINOR_CIV_FERTILITY = 50, 
		MIN_BARBARIAN_FERTILITY = 1,
		START_MIN_Y = 15,
		START_MAX_Y = 15,
		START_CONFIG = startConfig,
		WATER = true,
	};
	local start_plot_database = AssignStartingPlots.Create(args)

	local GoodyGen = AddGoodies(g_iW, g_iH);
end

-- Input a Hash; Export width, height, and wrapX
function GetMapInitData(MapSize)
	local Width = 99;
	local Height = 102;
	local WrapX = false;
	return {Width = Width, Height = Height, WrapX = WrapX,}
end
-------------------------------------------------------------------------------
function GeneratePlotTypes()
	print("Generating Plot Types");
	local plotTypes = {};

	-- Start with it all as water
	for x = 0, g_iW - 1 do
		for y = 0, g_iH - 1 do
			local i = y * g_iW + x;
			local pPlot = Map.GetPlotByIndex(i);
			plotTypes[i] = g_PLOT_TYPE_OCEAN;
			TerrainBuilder.SetTerrainType(pPlot, g_TERRAIN_TYPE_OCEAN);
		end
	end

	-- Each land strip is defined by: Y, X Start, X End
	local xOffset = 0;
	local yOffset = 0;
	local landStrips = {
		{0, 0, 34},
		{0, 47, 98},
		{1, 0, 36},
		{1, 48, 98},
		{2, 0, 37},
		{2, 49, 57},
		{2, 59, 98},
		{3, 0, 36},
		{3, 50, 56},
		{3, 59, 98},
		{4, 0, 35},
		{4, 54, 57},
		{4, 59, 98},
		{5, 0, 35},
		{5, 59, 59},
		{5, 62, 98},
		{6, 0, 35},
		{6, 50, 50},
		{6, 65, 98},
		{7, 0, 34},
		{7, 47, 49},
		{7, 66, 98},
		{8, 0, 33},
		{8, 65, 98},
		{9, 0, 32},
		{9, 65, 98},
		{10, 0, 31},
		{10, 67, 98},
		{11, 0, 30},
		{11, 70, 98},
		{12, 0, 23},
		{12, 70, 98},
		{13, 0, 21},
		{13, 70, 98},
		{14, 0, 18},
		{14, 71, 98},
		{15, 0, 15},
		{15, 71, 98},
		{16, 0, 15},
		{16, 72, 98},
		{17, 0, 15},
		{17, 73, 98},
		{18, 0, 14},
		{18, 73, 98},
		{19, 1, 14},
		{19, 73, 76},
		{19, 78, 98},
		{20, 1, 13},
		{20, 72, 73},
		{20, 79, 98},
		{21, 1, 1},
		{21, 3, 13},
		{21, 66, 67},
		{21, 73, 74},
		{21, 81, 98},
		{22, 3, 12},
		{22, 67, 68},
		{22, 73, 73},
		{22, 80, 81},
		{22, 84, 98},
		{23, 1, 10},
		{23, 12, 13},
		{23, 61, 61},
		{23, 69, 70},
		{23, 83, 98},
		{24, 0, 8},
		{24, 10, 10},
		{24, 69, 71},
		{24, 65, 65},
		{24, 75, 75},
		{24, 82, 98},
		{25, 0, 8},
		{25, 69, 72},
		{25, 81, 98},
		{26, 0, 8},
		{26, 71, 72},
		{26, 80, 98},
		{27, 0, 6},
		{27, 12, 15},
		{27, 80, 98},
		{28, 0, 5},
		{28, 12, 16},
		{28, 80, 98},
		{29, 0, 1},
		{29, 3, 4},
		{29, 11, 17},
		{29, 81, 98},
		{30, 0, 1},
		{30, 3, 3},
		{30, 6, 7},
		{30, 13, 18},
		{30, 81, 81},
		{30, 83, 98},
		{31, 5, 7},
		{31, 9, 9},
		{31, 11, 12},
		{31, 14, 18},
		{31, 84, 98},
		{32, 3, 6},
		{32, 8, 18},
		{32, 84, 98},
		{33, 2, 6},
		{33, 8, 17},
		{33, 83, 98},
		{34, 2, 16},
		{34, 22, 22},
		{34, 83, 98},
		{35, 0, 13},
		{35, 20, 22},
		{35, 84, 98},
		{36, 0, 12},
		{36, 18, 18},
		{36, 21, 22},
		{36, 84, 98},
		{37, 0, 11},
		{37, 16, 20},
		{37, 22, 23},
		{37, 83, 83},
		{37, 85, 98},
		{38, 2, 9},
		{38, 16, 19},
		{38, 23, 23},
		{38, 79, 82},
		{38, 86, 98},
		{39, 1, 11},
		{39, 16, 17},
		{39, 78, 84},
		{39, 87, 98},
		{40, 1, 5},
		{40, 7, 12},
		{40, 16, 19},
		{40, 22, 23},
		{40, 78, 98},
		{41, 3, 4},
		{41, 11, 12},
		{41, 16, 17},
		{41, 20, 20},
		{41, 23, 24},
		{41, 79, 98},
		{42, 3, 3},
		{42, 10, 10},
		{42, 24, 24},
		{42, 78, 98},
		{43, 8, 11},
		{43, 18, 18},
		{43, 20, 21},
		{43, 78, 98},
		{44, 0, 2},
		{44, 6, 12},
		{44, 16, 18},
		{44, 23, 23},
		{44, 75, 75},
		{44, 77, 98},
		{45, 0, 1},
		{45, 7, 12},
		{45, 15, 18},
		{45, 21, 21},
		{45, 23, 25},
		{45, 74, 75},
		{45, 79, 98},
		{46, 1, 5},
		{46, 7, 11},
		{46, 15, 18},
		{46, 21, 23},
		{46, 76, 76},
		{46, 81, 98},
		{47, 2, 6},
		{47, 26, 26},
		{47, 72, 74},
		{47, 81, 98},
		{48, 0, 6},
		{48, 8, 11},
		{48, 14, 15},
		{48, 18, 18},
		{48, 22, 22},
		{48, 71, 74},
		{48, 79, 79},
		{48, 81, 98},
		{49, 0, 4},
		{49, 9, 12},
		{49, 17, 18},
		{49, 20, 20},
		{49, 25, 28},
		{49, 70, 74},
		{49, 82, 98},
		{50, 0, 1},
		{50, 10, 11},
		{50, 14, 17},
		{50, 22, 28},
		{50, 72, 73},
		{50, 83, 98},
		{51, 6, 8},
		{51, 13, 18},
		{51, 20, 20},
		{51, 22, 26},
		{51, 30, 30},
		{51, 70, 70},
		{51, 79, 79},
		{51, 83, 98},
		{52, 4, 4},
		{52, 6, 10},
		{52, 13, 15},
		{52, 18, 18},
		{52, 24, 24},
		{52, 27, 31},
		{52, 84, 98},
		{53, 3, 11},
		{53, 13, 15},
		{53, 18, 20},
		{53, 22, 22},
		{53, 26, 26},
		{53, 28, 31},
		{53, 87, 98},
		{54, 3, 6},
		{54, 11, 11},
		{54, 13, 15},
		{54, 18, 26},
		{54, 28, 33},
		{54, 85, 85},
		{54, 87, 98},
		{55, 1, 1},
		{55, 3, 9},
		{55, 13, 16},
		{55, 18, 33},
		{55, 70, 70},
		{55, 78, 78},
		{55, 87, 98},
		{56, 0, 1},
		{56, 3, 11},
		{56, 13, 16},
		{56, 18, 34},
		{56, 83, 83},
		{56, 87, 98},
		{57, 0, 1},
		{57, 3, 9},
		{57, 14, 15},
		{57, 18, 19},
		{57, 22, 34},
		{57, 73, 73},
		{57, 87, 89},
		{57, 92, 98},
		{58, 3, 7},
		{58, 11, 11},
		{58, 26, 34},
		{58, 91, 98},
		{59, 2, 7},
		{59, 10, 11},
		{59, 23, 23},
		{59, 32, 33},
		{59, 66, 66},
		{59, 90, 98},
		{60, 3, 8},
		{60, 10, 10},
		{60, 21, 21},
		{60, 23, 24},
		{60, 28, 30},
		{60, 68, 68},
		{60, 89, 98},
		{61, 4, 8},
		{61, 23, 25},
		{61, 28, 34},
		{61, 64, 64},
		{61, 67, 68},
		{61, 88, 98},
		{62, 3, 8},
		{62, 20, 38},
		{62, 66, 68},
		{62, 78, 78},
		{62, 90, 97},
		{63, 1, 7},
		{63, 19, 40},
		{63, 67, 69},
		{63, 78, 79},
		{63, 90, 96},
		{64, 0, 7},
		{64, 20, 42},
		{64, 67, 67},
		{64, 78, 79},
		{64, 86, 89},
		{64, 95, 96},
		{64, 98, 98},
		{65, 0, 7},
		{65, 20, 42},
		{65, 65, 65},
		{65, 78, 79},
		{65, 86, 93},
		{66, 0, 6},
		{66, 20, 42},
		{66, 66, 66},
		{66, 78, 79},
		{66, 88, 98},
		{67, 0, 6},
		{67, 21, 43},
		{67, 78, 79},
		{67, 90, 98},
		{68, 0, 6},
		{68, 21, 41},
		{68, 78, 79},
		{68, 90, 98},
		{69, 0, 5},
		{69, 20, 42},
		{69, 78, 80},
		{69, 91, 94},
		{69, 97, 98},
		{70, 0, 2},
		{70, 4, 4},
		{70, 20, 45},
		{70, 61, 62},
		{70, 78, 80},
		{70, 96, 98},
		{71, 0, 2}, 
		{71, 19, 44},
		{71, 79, 81},
		{71, 94, 98},
		{72, 0, 2},
		{72, 18, 43},
		{72, 58, 59},
		{72, 80, 81},
		{72, 93, 98},
		{73, 0, 2},
		{73, 17, 42},
		{73, 57, 59},
		{73, 80, 82},
		{73, 92, 98},
		{74, 0, 1},
		{74, 16, 40},
		{74, 55, 56},
		{74, 81, 82},
		{74, 91, 98},
		{75, 0, 1},
		{75, 14, 40},
		{75, 54, 58},
		{75, 81, 84},
		{75, 89, 90},
		{75, 92, 98},
		{76, 0, 1},
		{76, 14, 39},
		{76, 55, 59},
		{76, 82, 87},
		{76, 93, 98},
		{77, 0, 1},
		{77, 12, 12},
		{77, 14, 40},
		{77, 55, 55},
		{77, 57, 58},
		{77, 60, 61},
		{77, 83, 86},
		{77, 92, 98},
		{78, 11, 12},
		{78, 14, 39},
		{78, 56, 58},
		{78, 92, 98},
		{79, 10, 11},
		{79, 13, 38},
		{79, 57, 58},
		{79, 91, 98},
		{80, 11, 11},
		{80, 13, 37},
		{80, 39, 39},
		{80, 58, 58},
		{80, 89, 89},
		{80, 91, 98},
		{81, 9, 9},
		{81, 12, 38},
		{81, 89, 98},
		{82, 7, 9},
		{82, 11, 38},
		{82, 86, 86},
		{82, 89, 98},
		{83, 5, 38},
		{83, 86, 87},
		{83, 89, 98},
		{84, 4, 38},
		{84, 89, 98},
		{85, 4, 37},
		{85, 61, 61},
		{85, 89, 98},
		{86, 3, 35},
		{86, 85, 85},
		{86, 89, 98},
		{87, 3, 33},
		{87, 84, 86},
		{87, 90, 98},
		{88, 2, 34},
		{88, 85, 86},
		{88, 90, 98},
		{89, 2, 32},
		{89, 86, 98},
		{90, 1, 32},
		{90, 70, 71},
		{90, 88, 98},
		{91, 1, 29},
		{91, 31, 32},
		{91, 69, 72},
		{91, 75, 84},
		{91, 88, 98},
		{92, 1, 28},
		{92, 31, 32},
		{92, 67, 85},
		{92, 87, 98},
		{93, 0, 29},
		{93, 32, 32},
		{93, 66, 85},
		{93, 87, 98}, 
		{94, 0, 30},
		{94, 66, 84},
		{94, 87, 98},
		{95, 0, 20},
		{95, 23, 29},
		{95, 43, 43},
		{95, 64, 84},
		{95, 87, 98},
		{96, 0, 10},
		{96, 14, 18},
		{96, 64, 82},
		{96, 88, 98},
		{97, 0, 9},
		{97, 63, 78},
		{97, 87, 98},
		{98, 0, 8},
		{98, 63, 81},
		{98, 84, 98},
		{99, 0, 5},
		{99, 62, 82},
		{99, 87, 98},
		{100, 0, 4},
		{100, 62, 83},
		{100, 87, 98},
		{101, 0, 2},
		{101, 61, 61},
		{101, 62, 98},
		{102, 0, 1},
		{102, 63, 98}};
		
	for i, v in ipairs(landStrips) do
		local y = g_iH - (v[1] + yOffset);   -- inverted 
		local xStart = v[2] + xOffset;
		local xEnd = v[3] + xOffset; 
		for x = xStart, xEnd do
			local i = y * g_iW + x;
			local pPlot = Map.GetPlotByIndex(i);
			plotTypes[i] = g_PLOT_TYPE_LAND;
			TerrainBuilder.SetTerrainType(pPlot, g_TERRAIN_TYPE_SNOW);  -- temporary setting so can calculate areas
			g_iNumTotalLandTiles = g_iNumTotalLandTiles + 1;
		end
	end
		
	AreaBuilder.Recalculate();

	--	world_age
	local world_age_new = 5;
	local world_age_normal = 3;
	local world_age_old = 2;

	local world_age = MapConfiguration.GetValue("world_age");
	if (world_age == 1) then
		world_age = world_age_new;
	elseif (world_age == 2) then
		world_age = world_age_normal;
	elseif (world_age == 3) then
		world_age = world_age_old;
	else
		world_age = 2 + TerrainBuilder.GetRandomNumber(4, "Random World Age - Lua");
	end
	
	local args = {};
	args.world_age = world_age;
	args.iW = g_iW;
	args.iH = g_iH
	args.iFlags = g_iFlags;
	args.blendRidge = 10;
	args.blendFract = 1;
	args.extra_mountains = 4;
	plotTypes = ApplyTectonics(args, plotTypes);

	return plotTypes;
end

function InitFractal(args)

	if(args == nil) then args = {}; end

	local continent_grain = args.continent_grain or 2;
	local rift_grain = args.rift_grain or -1; -- Default no rifts. Set grain to between 1 and 3 to add rifts. - Bob
	local invert_heights = args.invert_heights or false;
	local polar = args.polar or true;
	local ridge_flags = args.ridge_flags or g_iFlags;

	local fracFlags = {};
	
	if(invert_heights) then
		fracFlags.FRAC_INVERT_HEIGHTS = true;
	end
	
	if(polar) then
		fracFlags.FRAC_POLAR = true;
	end
	
	if(rift_grain > 0 and rift_grain < 4) then
		local riftsFrac = Fractal.Create(g_iW, g_iH, rift_grain, {}, 6, 5);
		g_continentsFrac = Fractal.CreateRifts(g_iW, g_iH, continent_grain, fracFlags, riftsFrac, 6, 5);
	else
		g_continentsFrac = Fractal.Create(g_iW, g_iH, continent_grain, fracFlags, 6, 5);	
	end

	-- Use Brian's tectonics method to weave ridgelines in to the continental fractal.
	-- Without fractal variation, the tectonics come out too regular.
	--
	--[[ "The principle of the RidgeBuilder code is a modified Voronoi diagram. I 
	added some minor randomness and the slope might be a little tricky. It was 
	intended as a 'whole world' modifier to the fractal class. You can modify 
	the number of plates, but that is about it." ]]-- Brian Wade - May 23, 2009
	--
	local MapSizeTypes = {};
	for row in GameInfo.Maps() do
		MapSizeTypes[row.MapSizeType] = row.PlateValue;
	end
	local sizekey = Map.GetMapSize();

	local numPlates = MapSizeTypes[sizekey] or 4

	-- Blend a bit of ridge into the fractal.
	-- This will do things like roughen the coastlines and build inland seas. - Brian

	g_continentsFrac:BuildRidges(numPlates, {}, 1, 2);
end

function AddFeatures()
	print("Adding Features");

	-- Get Rainfall setting input by user.
	local rainfall = MapConfiguration.GetValue("rainfall");
	
	local args = {rainfall = rainfall, iJunglePercent = 0, iMarshPercent = 4, iForestPercent = 55, iReefPercent = 0}	-- no rainforest
	local featuregen = FeatureGenerator.Create(args);

	featuregen:AddFeatures();

	-- add forest more densely at edges
	for iX = 0, g_iW - 1 do
		for iY = 0, g_iH - 1 do
			local index = (iY * g_iW) + iX;
			local plot = Map.GetPlot(iX, iY);
			local iDistanceFromCenter = __GetPlotDistance(iX, iY, g_CenterX, g_CenterY);

			-- like Australia floodplain logic
			if (TerrainBuilder.GetRandomNumber(40, "Resource Placement Score Adjust") < iDistanceFromCenter) then
				featuregen:AddForestsAtPlot(plot, iX, iY);
			end
		end
	end
end

------------------------------------------------------------------------------
function GenerateTerrainTypesArctic(plotTypes, iW, iH, iFlags, bNoCoastalMountains)
	print("Generating Terrain Types");
	local terrainTypes = {};

	local fracXExp = -1;
	local fracYExp = -1;
	local grain_amount = 3;

	arctic = Fractal.Create(iW, iH, 
									grain_amount, iFlags, 
									fracXExp, fracYExp);

	for iX = 0, iW - 1 do
		for iY = 0, iH - 1 do
			local index = (iY * iW) + iX;
			if (plotTypes[index] == g_PLOT_TYPE_OCEAN) then
				if (IsAdjacentToLand(plotTypes, iX, iY)) then
					terrainTypes[index] = g_TERRAIN_TYPE_COAST;
				else
					terrainTypes[index] = g_TERRAIN_TYPE_OCEAN;
				end
			end
		end
	end

	if (bNoCoastalMountains == true) then
		plotTypes = RemoveCoastalMountains(plotTypes, terrainTypes);
	end

	for iX = 0, iW - 1 do
		for iY = 0, iH - 1 do
			local index = (iY * iW) + iX;

			local iDistanceFromCenter = __GetPlotDistance(iX, iY, g_CenterX, g_CenterY);
			local lat = GetRadialLatitudeAtPlot(arctic, iX, iY);

			local iSnowTop = arctic:GetHeight(100);	
			local iSnowBottom = arctic:GetHeight(75);
											
			local iTundraTop = arctic:GetHeight(75);										
			local iTundraBottom = arctic:GetHeight(10 + iDistanceFromCenter/iH * 100/4);

			local iPlainsTop = arctic:GetHeight(10 + iDistanceFromCenter/iH * 100/4);
			local iPlainsBottom = arctic:GetHeight(10);

			-- north pole
			if (lat > 0.82) then
				if (plotTypes[index] == g_PLOT_TYPE_MOUNTAIN) then
					terrainTypes[index] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;
				elseif (plotTypes[index] ~= g_PLOT_TYPE_OCEAN) then
					terrainTypes[index] = g_TERRAIN_TYPE_SNOW;
				end

			elseif (lat > 0.79) then
				local tundraVal = arctic:GetHeight(iX, iY);
				
				if (plotTypes[index] == g_PLOT_TYPE_MOUNTAIN) then
					terrainTypes[index] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;

					if ((tundraVal >= iTundraBottom) and (tundraVal <= iTundraTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_TUNDRA_MOUNTAIN;
					end
				elseif (plotTypes[index] ~= g_PLOT_TYPE_OCEAN) then
					terrainTypes[index] = g_TERRAIN_TYPE_SNOW;

					if ((tundraVal >= iTundraBottom) and (tundraVal <= iTundraTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_TUNDRA;
					end
				end

			-- arctic circle
			elseif (lat > 0.75) then
				local tundraVal = arctic:GetHeight(iX, iY);
				local plainsVal = arctic:GetHeight(iX, iY);

				if (plotTypes[index] == g_PLOT_TYPE_MOUNTAIN) then
					terrainTypes[index] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;

					if ((tundraVal >= iTundraBottom) and (tundraVal <= iTundraTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_TUNDRA_MOUNTAIN;
					elseif ((plainsVal >= iPlainsBottom) and (plainsVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS_MOUNTAIN;
					end

				elseif (plotTypes[index] ~= g_PLOT_TYPE_OCEAN) then
					terrainTypes[index] = g_TERRAIN_TYPE_SNOW;
				
					if ((tundraVal >= iTundraBottom) and (tundraVal <= iTundraTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_TUNDRA;
					elseif ((plainsVal >= iPlainsBottom) and (plainsVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS;
					end
				end

			-- eurasia and north america
			else
				local snowVal = arctic:GetHeight(iX, iY);
				local tundraVal = arctic:GetHeight(iX, iY);
				local plainsVal = arctic:GetHeight(iX, iY);

				if (plotTypes[index] == g_PLOT_TYPE_MOUNTAIN) then
					terrainTypes[index] = g_TERRAIN_TYPE_GRASS_MOUNTAIN;

					if ((snowVal >= iSnowBottom) and (snowVal <= iSnowTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;
					elseif ((tundraVal >= iTundraBottom) and (tundraVal <= iTundraTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_TUNDRA_MOUNTAIN;
					elseif ((plainsVal >= iPlainsBottom) and (plainsVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS_MOUNTAIN;
					end

				elseif (plotTypes[index] ~= g_PLOT_TYPE_OCEAN) then
					terrainTypes[index] = g_TERRAIN_TYPE_GRASS;
				
					if ((snowVal >= iSnowBottom) and (snowVal <= iSnowTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_SNOW;
					elseif ((tundraVal >= iTundraBottom) and (tundraVal <= iTundraTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_TUNDRA;
					elseif ((plainsVal >= iPlainsBottom) and (plainsVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS;
					end
				end

			end
		end
	end

	local bExpandCoasts = true;

	if bExpandCoasts == false then
		return
	end

	print("Expanding coasts");
	for iI = 0, 2 do
		local shallowWaterPlots = {};
		for iX = 0, iW - 1 do
			for iY = 0, iH - 1 do
				local index = (iY * iW) + iX;
				if (terrainTypes[index] == g_TERRAIN_TYPE_OCEAN) then
					-- Chance for each eligible plot to become an expansion is 1 / iExpansionDiceroll.
					-- Default is two passes at 1/4 chance per eligible plot on each pass.
					if (IsAdjacentToShallowWater(terrainTypes, iX, iY) and TerrainBuilder.GetRandomNumber(4, "add shallows") == 0) then
						table.insert(shallowWaterPlots, index);
					end
				end
			end
		end
		for i, index in ipairs(shallowWaterPlots) do
			terrainTypes[index] = g_TERRAIN_TYPE_COAST;
		end
	end
	
	return terrainTypes; 
end
------------------------------------------------------------------------------

-- override: circular poles
function FeatureGenerator:AddIceAtPlot(plot, iX, iY)
	local lat = GetRadialLatitudeAtPlot(arctic, iX, iY);
	
	if (lat > 0.85) then
		local iScore = TerrainBuilder.GetRandomNumber(100, "Resource Placement Score Adjust");

		iScore = iScore + lat * 100;

		if(IsAdjacentToLandPlot(iX,iY) == true) then
			iScore = iScore / 2.0;
		end

		local iAdjacent = TerrainBuilder.GetAdjacentFeatureCount(plot, g_FEATURE_ICE);
		iScore = iScore + 10.0 * iAdjacent;

		if(iScore > 130) then
			TerrainBuilder.SetFeatureType(plot, g_FEATURE_ICE);
		end
	end
	
	return false;
end

------------------------------------------------------------------------------
-- bugfix/patch - remember pythagoras?
function __GetPlotDistance(iX1, iY1, iX0, iY0)
	return math.sqrt((iX1-iX0)^2 + (iY1-iY0)^2);
end

----------------------------------------------------------------------------------
-- LATITUDE LOOKUP
----------------------------------------------------------------------------------
function _GetRadialLatitudeAtPlot(variationFrac, iX, iY)
	local iZ = __GetPlotDistance(iX, iY, g_CenterX, g_CenterY);		-- radial distance from center

	if (iZ < 2*g_iE) then
		-- Terrain bands are governed by latitude (in rad).
		local _lat = 1/2 - iZ/(2*g_iE);

		-- Returns a latitude value between 0.0 (tropical) and +/-1.0 (polar).
		local lat = 2 * _lat;
	
		-- Adjust latitude using variation fractal, to roughen the border between bands:
		-- lessen the variation at south pole
		lat = lat + (128 - variationFrac:GetHeight(iX, iY))/(255.0 * 5.0) * (1 - iZ/(2*g_iE));

		-- Limit to the range [-1, 1]:
		lat = math.clamp(lat, -1, 1);
	
		return lat;
	else
		-- off the map (south pole) 
		return -1;
	end
end

-- Returns a latitude value between 0.0 (tropical) and 1.0 (polar).
function GetRadialLatitudeAtPlot(variationFrac, iX, iY)
	return math.abs(_GetRadialLatitudeAtPlot(variationFrac, iX, iY));
end