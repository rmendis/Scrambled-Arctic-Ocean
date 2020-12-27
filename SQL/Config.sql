-- Config
-- Author: blkbutterfly74
-- DateCreated: 1/15/2018 11:19:11 PM
--------------------------------------------------------------
INSERT INTO Maps (File, Domain, Name, Description)
VALUES 
	('{3773C7EF-1474-4EDB-8307-20722745BED8}Maps/Arctic.lua', 'StandardMaps', 'LOC_MAP_ARCTIC_NAME', 'LOC_MAP_ARCTIC_DESCRIPTION'),
	('{3773C7EF-1474-4EDB-8307-20722745BED8}Maps/Arctic_XP2.lua', 'Maps:Expansion2Maps', 'LOC_MAP_ARCTIC_NAME', 'LOC_MAP_ARCTIC_DESCRIPTION');

INSERT INTO DomainValueFilters (Domain, Value, Filter)
VALUES 
	('Maps:Expansion2Maps', '{3773C7EF-1474-4EDB-8307-20722745BED8}Maps/Arctic.lua', 'difference');

INSERT INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES
	-- rainfall
	('Map', '{3773C7EF-1474-4EDB-8307-20722745BED8}Maps/Arctic.lua', 'Rainfall', 'LOC_MAP_RAINFALL_NAME', 'LOC_MAP_RAINFALL_DESCRIPTION', 'Rainfall', 2, 'Map', 'rainfall', 'MapOptions', 250),

	-- world age
	('Map', '{3773C7EF-1474-4EDB-8307-20722745BED8}Maps/Arctic.lua', 'WorldAge', 'LOC_MAP_WORLD_AGE_NAME', 'LOC_MAP_WORLD_AGE_DESCRIPTION', 'WorldAge', 2, 'Map', 'world_age', 'MapOptions', 230),

		-- rainfall
	('Map', '{3773C7EF-1474-4EDB-8307-20722745BED8}Maps/Arctic_XP2.lua', 'Rainfall', 'LOC_MAP_RAINFALL_NAME', 'LOC_MAP_RAINFALL_DESCRIPTION', 'Rainfall', 2, 'Map', 'rainfall', 'MapOptions', 250),

	-- world age
	('Map', '{3773C7EF-1474-4EDB-8307-20722745BED8}Maps/Arctic_XP2.lua', 'WorldAge', 'LOC_MAP_WORLD_AGE_NAME', 'LOC_MAP_WORLD_AGE_DESCRIPTION', 'WorldAge', 2, 'Map', 'world_age', 'MapOptions', 230);