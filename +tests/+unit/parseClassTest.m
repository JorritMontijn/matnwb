function tests = parseClassTest()
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
rootPath = fullfile(fileparts(mfilename('fullpath')), '..', '..');
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(rootPath));
schemaPath = fullfile(rootPath, 'jar', 'schema.jar');
if ~any(strcmpi(javaclasspath, schemaPath))
  javaaddpath(schemaPath);
end
end

function setup(testCase)
testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
end

%% Parse class (i.e. top-level groups) tests

function testParseClassWithNeurodataTypeDef(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass'});
act = yaml.getSourceInfo('.', 'test.yaml'); gc;
exp.TestClass.namespace = 'ns';
testCase.verifyEqual(act, exp);
end

function testParseClassWithoutNeurodataTypeDefThrows(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- doc: A string describing the group'});
testCase.verifyError(@()yaml.getSourceInfo('.', 'test.yaml'), ?MException); gc;
end

function testParseMultipleClassesWithNeurodataTypeDef(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass1', ...
  '- neurodata_type_def: TestClass2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass1.namespace = 'ns';
exp.TestClass2.namespace = 'ns';
testCase.verifyEqual(act, exp);
end

function testParseClassWithBasicSpecKeys(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  default_name: MyName', ...
  '  doc: A string describing the group', ...
  '  neurodata_type_inc: TestSuperClass', ...
  '  quantity: +', ...
  '  linkable: true'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.default_name = 'MyName';
exp.TestClass.doc = 'A string describing the group';
exp.TestClass.neurodata_type_inc = 'TestSuperClass';
exp.TestClass.quantity = '+';
exp.TestClass.linkable = 'true';
testCase.verifyEqual(act, exp);
end

function testParseClassWithAttributes(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  attributes:', ...
  '  - name: a1', ...
  '  - name: a2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.attributes.a1 = struct();
exp.TestClass.attributes.a2 = struct();
testCase.verifyEqual(act, exp);
end

function testParseClassWithLinks(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  links:', ...
  '  - name: l1', ...
  '  - name: l2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.links.l1 = struct();
exp.TestClass.links.l2 = struct();
testCase.verifyEqual(act, exp);
end

function testParseClassWithDatasets(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  datasets:', ...
  '  - name: d1', ...
  '  - name: d2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.datasets.d1 = struct();
exp.TestClass.datasets.d2 = struct();
testCase.verifyEqual(act, exp);
end

function testParseClassWithGroups(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  groups:', ...
  '  - name: g1', ...
  '  - name: g2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.groups.g1 = struct();
exp.TestClass.groups.g2 = struct();
testCase.verifyEqual(act, exp);
end

%% Parse attribute tests

function testParseAttributeWithBasicSpecKeys(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  attributes:', ...
  '  - name: a1', ...
  '    doc: A string describing the attribute', ...
  '    required: true', ...
  '    value: myConstValue', ...
  '    defaultValue: myValue'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.attributes.a1.doc = 'A string describing the attribute';
exp.TestClass.attributes.a1.required = 'true';
exp.TestClass.attributes.a1.value = 'myConstValue';
exp.TestClass.attributes.a1.defaultValue = 'myValue';
testCase.verifyEqual(act, exp);
end

function testParseAttributeWithDtype(testCase)
stype2mtype = map( ...
  'float', 'single', ...
  'float32', 'single', ...
  'double', 'double', ...
  'float64', 'double', ...
  'long', 'int64', ...
  'int64', 'int64', ...
  'int', 'int32', ...
  'int32', 'int32', ...
  'int16', 'int16', ...
  'int8', 'int8', ...
  'uint32', 'uint32', ...
  'uint16', 'uint16', ...
  'uint8', 'uint8', ...
  'text', 'string', ...
  'utf', 'string', ...
  'utf8', 'string', ...
  'utf-8', 'string', ...
  'ascii', 'string', ...
  'str', 'string');
stypes = stype2mtype.keys;
for i = 1:numel(stypes)
  stype = stypes{i};
  ymlwrite('test.yaml', { ...
    'groups:', ...
    '- neurodata_type_def: TestClass', ...
    '  attributes:', ...
    '  - name: a1', ...
   ['    dtype: ' stype]});
  act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
  exp.TestClass.namespace = 'ns';
  exp.TestClass.attributes.a1.dtype = stype2mtype(stype);
  testCase.verifyEqual(act, exp, ...
    ['Expected dtype ''' stype ''' to be parsed as ''' stype2mtype(stype) '''']);
end
end

function testParseAttributeWithDims(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  attributes:', ...
  '  - name: a1', ...
  '    dims:', ...
  '    - dim1', ...
  '    - dim2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.attributes.a1.dims = {'dim1'; 'dim2'};
testCase.verifyEqual(act, exp);
end

function testParseAttributeWithMultipleDims(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  attributes:', ...
  '  - name: a1', ...
  '    dims:', ...
  '    - - dim1', ...
  '    - - dim1', ...
  '      - dim2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.attributes.a1.dims = {{'dim1'}; {'dim1';'dim2'}};
testCase.verifyEqual(act, exp);
end

function testParseAttributeWithShapes(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  attributes:', ...
  '  - name: a1', ...
  '    shape:', ...
  '    - 1', ...
  '    - 2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.attributes.a1.shape = {'1'; '2'};
testCase.verifyEqual(act, exp);
end

function testParseAttributeWithMultipleShapes(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  attributes:', ...
  '  - name: a1', ...
  '    shape:', ...
  '    - - 1', ...
  '    - - 1', ...
  '      - 2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.attributes.a1.shape = {{'1'}; {'1';'2'}};
testCase.verifyEqual(act, exp);
end

%% Parse link tests

function testParseLinkWithBasicSpecKeys(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  links:', ...
  '  - target_type: TestTargetType', ...
  '    name: l1', ...
  '    doc: A string describing the link'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.links.l1.target_type = 'TestTargetType';
exp.TestClass.links.l1.doc = 'A string describing the link';
testCase.verifyEqual(act, exp);
end

%% Parse dataset tests

function testParseDatasetWithBasicSpecKeys(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  datasets:', ...
  '  - name: d1', ...
  '    default_name: MyName', ...
  '    doc: A string describing the dataset', ...
  '    neurodata_type_inc: TestSuperClass', ...
  '    quantity: +', ...
  '    linkable: true'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.datasets.d1.default_name = 'MyName';
exp.TestClass.datasets.d1.doc = 'A string describing the dataset';
exp.TestClass.datasets.d1.neurodata_type_inc = 'TestSuperClass';
exp.TestClass.datasets.d1.quantity = '+';
exp.TestClass.datasets.d1.linkable = 'true';
testCase.verifyEqual(act, exp);
end

function testParseDatasetWithNeurodataTypeDef(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  datasets:', ...
  '  - neurodata_type_def: TestDataset'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
ds = act.TestClass.datasets;
act.TestClass = rmfield(act.TestClass, 'datasets');
exp.TestDataset.namespace = 'ns';
exp.TestClass.namespace = 'ns';
testCase.verifyEqual(act, exp);
fn = fieldnames(ds);
testCase.verifyEqual(numel(fn), 1);
testCase.verifyEqual(ds.(fn{1}).type, 'TestDataset');
end

function testParseDatasetWithDtype(testCase)
stype2mtype = map( ...
  'float', 'single', ...
  'float32', 'single', ...
  'double', 'double', ...
  'float64', 'double', ...
  'long', 'int64', ...
  'int64', 'int64', ...
  'int', 'int32', ...
  'int32', 'int32', ...
  'int16', 'int16', ...
  'int8', 'int8', ...
  'uint32', 'uint32', ...
  'uint16', 'uint16', ...
  'uint8', 'uint8', ...
  'text', 'string', ...
  'utf', 'string', ...
  'utf8', 'string', ...
  'utf-8', 'string', ...
  'ascii', 'string', ...
  'str', 'string');
stypes = stype2mtype.keys;
for i = 1:numel(stypes)
  stype = stypes{i};
  ymlwrite('test.yaml', { ...
    'groups:', ...
    '- neurodata_type_def: TestClass', ...
    '  datasets:', ...
    '  - name: d1', ...
   ['    dtype: ' stype]});
  act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
  exp.TestClass.namespace = 'ns';
  exp.TestClass.datasets.d1.dtype = stype2mtype(stype);
  testCase.verifyEqual(act, exp, ...
    ['Expected dtype ''' stype ''' to be parsed as ''' stype2mtype(stype) '''']);
end
end

function testParseDatasetWithDims(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  datasets:', ...
  '  - name: d1', ...
  '    dims:', ...
  '    - dim1', ...
  '    - dim2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.datasets.d1.dims = {'dim1'; 'dim2'};
testCase.verifyEqual(act, exp);
end

function testParseDatasetWithMultipleDims(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  datasets:', ...
  '  - name: d1', ...
  '    dims:', ...
  '    - - dim1', ...
  '    - - dim1', ...
  '      - dim2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.datasets.d1.dims = {{'dim1'}; {'dim1';'dim2'}};
testCase.verifyEqual(act, exp);
end

function testParseDatasetWithShapes(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  datasets:', ...
  '  - name: d1', ...
  '    shape:', ...
  '    - 1', ...
  '    - 2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.datasets.d1.shape = {'1'; '2'};
testCase.verifyEqual(act, exp);
end

function testParseDatasetWithMultipleShapes(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  datasets:', ...
  '  - name: d1', ...
  '    shape:', ...
  '    - - 1', ...
  '    - - 1', ...
  '      - 2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.datasets.d1.shape = {{'1'}; {'1';'2'}};
testCase.verifyEqual(act, exp);
end

function testParseDatasetWithAttributes(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  datasets:', ...
  '  - name: d1', ...
  '    attributes:', ...
  '    - name: a1', ...
  '    - name: a2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.datasets.d1.attributes.a1 = struct();
exp.TestClass.datasets.d1.attributes.a2 = struct();
testCase.verifyEqual(act, exp);
end

%% Write group (sub-groups of top-level group) tests

function testParseGroupWithBasicSpecKeys(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  groups:', ...
  '  - name: g1', ...
  '    default_name: MyName', ...
  '    doc: A string describing the group', ...
  '    neurodata_type_inc: TestSuperClass', ...
  '    quantity: +', ...
  '    linkable: true'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.groups.g1.default_name = 'MyName';
exp.TestClass.groups.g1.doc = 'A string describing the group';
exp.TestClass.groups.g1.neurodata_type_inc = 'TestSuperClass';
exp.TestClass.groups.g1.quantity = '+';
exp.TestClass.groups.g1.linkable = 'true';
testCase.verifyEqual(act, exp);
end

function testParseGroupWithNeurodataTypeDef(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  groups:', ...
  '  - neurodata_type_def: TestGroup'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
gs = act.TestClass.groups;
act.TestClass = rmfield(act.TestClass, 'groups');
exp.TestGroup.namespace = 'ns';
exp.TestClass.namespace = 'ns';
testCase.verifyEqual(act, exp);
fn = fieldnames(gs);
testCase.verifyEqual(numel(fn), 1);
testCase.verifyEqual(gs.(fn{1}).type, 'TestGroup');
end

function testParseGroupWithAttributes(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  groups:', ...
  '  - name: g1', ...
  '    attributes:', ...
  '    - name: a1', ...
  '    - name: a2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.groups.g1.attributes.a1 = struct();
exp.TestClass.groups.g1.attributes.a2 = struct();
testCase.verifyEqual(act, exp);
end

function testParseGroupWithLinks(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  groups:', ...
  '  - name: g1', ...
  '    links:', ...
  '    - name: l1', ...
  '    - name: l2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.groups.g1.links.l1 = struct();
exp.TestClass.groups.g1.links.l2 = struct();
testCase.verifyEqual(act, exp);
end

function testParseGroupWithDatasets(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  groups:', ...
  '  - name: g1', ...
  '    datasets:', ...
  '    - name: d1', ...
  '    - name: d2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.groups.g1.datasets.d1 = struct();
exp.TestClass.groups.g1.datasets.d2 = struct();
testCase.verifyEqual(act, exp);
end

function testParseGroupWithGroups(testCase)
ymlwrite('test.yaml', { ...
  'groups:', ...
  '- neurodata_type_def: TestClass', ...
  '  groups:', ...
  '  - name: g1', ...
  '    groups:', ...
  '    - name: g1', ...
  '    - name: g2'});
act = yaml.getSourceInfo('test.yaml', 'ns'); gc;
exp.TestClass.namespace = 'ns';
exp.TestClass.groups.g1.groups.g1 = struct();
exp.TestClass.groups.g1.groups.g2 = struct();
testCase.verifyEqual(act, exp);
end

%% Convenience functions

function ymlwrite(filename, lines)
fid = fopen(filename, 'w');
close = onCleanup(@()fclose(fid));
fprintf(fid, '%s\n', lines{:});
end

function gc()
java.lang.System.gc();
end

function m = map(varargin)
keys = {};
values = {};
for i = 1:2:numel(varargin)
  keys{end+1} = varargin{i};
  values{end+1} = varargin{i+1};
end
m = containers.Map(keys, values);
end
