/// Common interface for: [NamespaceDecl], [DataTypeDecl], [Program], [FunctionBlock], [Function]
abstract interface class GlobalNamespaceItem {}

/// Common interface for: [NamespaceDecl], [DataTypeDecl], [FunctionBlock], [Function]
abstract interface class NamespaceDeclItem {}

/// Common interface for: [InoutVars], [InputVars], [OutputVars]
abstract interface class ParameterSetItem {}

/// Common interface for: [TypeName], [InstantlyDefinedType]
abstract interface class TypeRef {}

/// Common interface for: [SimpleValue], [ArrayValue], [StructValue]
abstract interface class Value {}

/// Common interface for: [CommonObject], [LdObject], [FbdObject]
abstract interface class LadderRungItem {}

class Project {
  final FileHeader fileHeader;
  final ContentHeader contentHeader;
  final Types types;
  final Instances instances;
  final double schemaVersion;
  Project({
    required this.fileHeader,
    required this.contentHeader,
    required this.types,
    required this.instances,
    required this.schemaVersion,
  });
}

class FileHeader {
  final String companyName;
  final String productName;
  final String productVersion;
  FileHeader({
    required this.companyName,
    required this.productName,
    required this.productVersion,
  });
}

class ContentHeader {
  final AddDataInfo addDataInfo;
  final AddData addData;
  final String name;
  final DateTime creationDateTime;
  ContentHeader({
    required this.addDataInfo,
    required this.addData,
    required this.name,
    required this.creationDateTime,
  });
}

class AddDataInfo {
  final List<Info>? info;
  AddDataInfo({this.info});
}

class Info {
  final String name;
  final double version;
  final String vendor;
  Info({required this.name, required this.version, required this.vendor});
}

class Types {
  final GlobalNamespace globalNamespace;
  Types({required this.globalNamespace});
}

class GlobalNamespace extends TextualObjectBase {
  final List<GlobalNamespaceItem> items;
  GlobalNamespace({
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.items,
  });
}

class Instances {
  final List<Configuration>? configurations;
  Instances({this.configurations});
}

class Configuration extends TextualObjectBase {
  final List<Resource>? resources;
  Configuration({
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    this.resources,
  });
}

class Resource extends TextualObjectBase {
  final List<VarList>? globalVars;
  Resource({
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    this.globalVars,
  });
}

abstract class TypeSpecBase {
  TypeSpecBase();
}

abstract class InstantlyDefinableTypeSpecBase extends TypeSpecBase {
  InstantlyDefinableTypeSpecBase();
}

abstract class BehaviorRepresentationBase {
  BehaviorRepresentationBase();
}

abstract class ProgrammingLanguageBase extends BehaviorRepresentationBase {
  ProgrammingLanguageBase();
}

abstract class IdentifiedObjectBase {
  final TextBase documentation;
  final AddData addData;
  IdentifiedObjectBase({required this.documentation, required this.addData});
}

abstract class GraphicalObjectBase extends IdentifiedObjectBase {
  GraphicalObjectBase({required super.documentation, required super.addData});
}

abstract class CommonObjectBase extends GraphicalObjectBase {
  CommonObjectBase({required super.documentation, required super.addData});
}

abstract class FbdObjectBase extends GraphicalObjectBase {
  FbdObjectBase({required super.documentation, required super.addData});
}

abstract class LdObjectBase extends GraphicalObjectBase {
  LdObjectBase({required super.documentation, required super.addData});
}

abstract class NetworkBase extends GraphicalObjectBase {
  final String? label;
  final int evaluationOrder;
  NetworkBase({
    required super.documentation,
    required super.addData,
    this.label,
    required this.evaluationOrder,
  });
}

abstract class TextualObjectBase extends IdentifiedObjectBase {
  final List<String?>? usingDirectives;
  TextualObjectBase({
    required super.documentation,
    required super.addData,
    this.usingDirectives,
  });
}

abstract class NamespaceContentBase extends TextualObjectBase {
  final String name;
  NamespaceContentBase({
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.name,
  });
}

class NamespaceDecl extends NamespaceContentBase
    implements GlobalNamespaceItem, NamespaceDeclItem {
  final List<NamespaceDeclItem> items;
  NamespaceDecl({
    required super.name,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.items,
  });
}

class UserDefinedTypeDecl extends NamespaceContentBase {
  final TypeSpecBase userDefinedTypeSpec;
  UserDefinedTypeDecl({
    required super.name,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.userDefinedTypeSpec,
  });
}

class ArrayTypeSpec extends InstantlyDefinableTypeSpecBase {
  final TypeRef baseType;
  final List<DimensionSpec> dimensionSpecs;
  final AddData addData;
  ArrayTypeSpec({
    required this.baseType,
    required this.dimensionSpecs,
    required this.addData,
  });
}

class DimensionSpec {
  final int dimensionNumber;
  DimensionSpec({required this.dimensionNumber});
}

class IndexRange {
  final String lower;
  final String upper;
  IndexRange({required this.lower, required this.upper});
}

class EnumTypeSpec extends TypeSpecBase {
  final List<EnumeratorWithoutValue> enumerators;
  final AddData addData;
  EnumTypeSpec({required this.enumerators, required this.addData});
}

class EnumeratorWithoutValue {
  final TextBase documentation;
  final String name;
  EnumeratorWithoutValue({required this.documentation, required this.name});
}

class EnumTypeWithNamedValueSpec extends TypeSpecBase {
  final List<Enumerator> enumerators;
  final ElementaryType baseType;
  final AddData addData;
  EnumTypeWithNamedValueSpec({
    required this.enumerators,
    required this.baseType,
    required this.addData,
  });
}

class Enumerator {
  final TextBase documentation;
  final String name;
  final String value;
  Enumerator({
    required this.documentation,
    required this.name,
    required this.value,
  });
}

class StructTypeSpec extends TypeSpecBase {
  final List<VariableDecl> members;
  final AddData addData;
  StructTypeSpec({required this.members, required this.addData});
}

class Program extends NamespaceContentBase implements GlobalNamespaceItem {
  final List<ExternalVarList>? externalVars;
  final List<VarListWithAccessSpec>? vars;
  final Body mainBody;
  Program({
    required super.name,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    this.externalVars,
    this.vars,
    required this.mainBody,
  });
}

class FunctionBlock extends NamespaceContentBase
    implements GlobalNamespaceItem, NamespaceDeclItem {
  final ParameterSet parameters;
  final List<ExternalVarList>? externalVars;
  final List<VarListWithAccessSpec>? vars;
  final Body mainBody;
  FunctionBlock({
    required super.name,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.parameters,
    this.externalVars,
    this.vars,
    required this.mainBody,
  });
}

class Function$ extends NamespaceContentBase
    implements GlobalNamespaceItem, NamespaceDeclItem {
  final TypeRef resultType;
  final ParameterSet parameters;
  final List<ExternalVarList>? externalVars;
  final List<VarList>? tempVars;
  final BodyWithoutSFC mainBody;
  Function$({
    required super.name,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.resultType,
    required this.parameters,
    this.externalVars,
    this.tempVars,
    required this.mainBody,
  });
}

class ParameterSet {
  final List<ParameterSetItem> items;
  ParameterSet({required this.items});
}

class InoutVars implements ParameterSetItem {
  final List<ParameterInoutVariable>? variables;
  InoutVars({this.variables});
}

class ParameterInoutVariable extends VariableDecl {
  final int orderWithinParamSet;
  ParameterInoutVariable({
    required super.initialValue,
    required super.address,
    required super.type,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.orderWithinParamSet,
  });
}

class InputVars implements ParameterSetItem {
  final List<ParameterInputVariable>? variables;
  final bool? retain;
  final bool? nonRetain;
  InputVars({this.variables, this.retain, this.nonRetain});
}

class ParameterInputVariable extends VariableDecl {
  final int orderWithinParamSet;
  final EdgeModifierType edgeDetection;
  ParameterInputVariable({
    required super.initialValue,
    required super.address,
    required super.type,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.orderWithinParamSet,
    required this.edgeDetection,
  });
}

class OutputVars implements ParameterSetItem {
  final List<ParameterOutputVariable>? variables;
  final bool? retain;
  final bool? nonRetain;
  OutputVars({this.variables, this.retain, this.nonRetain});
}

class ParameterOutputVariable extends VariableDecl {
  final int orderWithinParamSet;
  ParameterOutputVariable({
    required super.initialValue,
    required super.address,
    required super.type,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.orderWithinParamSet,
  });
}

class VarListWithAccessSpec extends VarList {
  final AccessSpecifiers accessSpecifier;
  VarListWithAccessSpec({
    super.variables,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.accessSpecifier,
  });
}

class Body extends TextualObjectBase {
  final List<BehaviorRepresentationBase> bodyContents;
  Body({
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.bodyContents,
  });
}

class BodyWithoutSFC extends TextualObjectBase {
  final List<ProgrammingLanguageBase> bodyContents;
  BodyWithoutSFC({
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.bodyContents,
  });
}

class VarList extends TextualObjectBase {
  final List<VariableDecl>? variables;
  VarList({
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    this.variables,
  });
}

class ExternalVarList extends TextualObjectBase {
  final List<VariableDeclPlain>? variables;
  ExternalVarList({
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    this.variables,
  });
}

class VariableDecl extends VariableDeclPlain {
  final Value initialValue;
  final AddressExpression address;
  VariableDecl({
    required super.type,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.initialValue,
    required this.address,
  });
}

class VariableDeclPlain extends TextualObjectBase {
  final TypeRef type;
  VariableDeclPlain({
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    required this.type,
  });
}

class SimpleValue implements Value {
  final String? value;
  SimpleValue({this.value});
}

class ArrayValue implements Value {
  final ArrayValueItem value;
  ArrayValue({required this.value});
}

class ArrayValueItem extends Value {
  final String? repetitionValue;
  ArrayValueItem({this.repetitionValue});
}

class StructValue implements Value {
  final StructValueItem value;
  StructValue({required this.value});
}

class StructValueItem extends Value {
  final String member;
  StructValueItem({required this.member});
}

class AddressExpression extends FixedAddressExpression {
  AddressExpression({
    super.address,
    super.usingDirectives,
    required super.documentation,
    required super.addData,
  });
}

class FixedAddressExpression extends TextualObjectBase {
  final String? address;
  FixedAddressExpression({
    super.usingDirectives,
    required super.documentation,
    required super.addData,
    this.address,
  });
}

class ST extends ProgrammingLanguageBase {
  final String st;
  ST({required this.st});
}

class LD extends ProgrammingLanguageBase {
  final List<LadderRung>? rungs;
  LD({this.rungs});
}

class LadderRung extends NetworkBase {
  final List<LadderRungItem> items;
  LadderRung({
    super.label,
    required super.evaluationOrder,
    required super.documentation,
    required super.addData,
    required this.items,
  });
}

class Comment extends CommonObjectBase {
  final TextBase content;
  Comment({
    required super.documentation,
    required super.addData,
    required this.content,
  });
}

class Block extends FbdObjectBase {
  final InOutVariables inOutVariables;
  final InputVariables inputVariables;
  final OutputVariables outputVariables;
  Block({
    required super.documentation,
    required super.addData,
    required this.inOutVariables,
    required this.inputVariables,
    required this.outputVariables,
  });
}

class InOutVariables {
  final List<InOutVariable>? inOutVariables;
  InOutVariables({this.inOutVariables});
}

class InOutVariable extends IdentifiedObjectBase {
  final ConnectionPointIn connectionPointIn;
  final ConnectionPointOut connectionPointOut;
  InOutVariable({
    required super.documentation,
    required super.addData,
    required this.connectionPointIn,
    required this.connectionPointOut,
  });
}

class InputVariables {
  final List<InputVariable>? inputVariables;
  InputVariables({this.inputVariables});
}

class InputVariable extends IdentifiedObjectBase {
  final ConnectionPointIn connectionPointIn;
  InputVariable({
    required super.documentation,
    required super.addData,
    required this.connectionPointIn,
  });
}

class OutputVariables {
  final List<OutputVariable>? outputVariables;
  OutputVariables({this.outputVariables});
}

class OutputVariable extends IdentifiedObjectBase {
  final ConnectionPointOut connectionPointOut;
  OutputVariable({
    required super.documentation,
    required super.addData,
    required this.connectionPointOut,
  });
}

class DataSource extends FbdObjectBase {
  final ConnectionPointOut connectionPointOut;
  DataSource({
    required super.documentation,
    required super.addData,
    required this.connectionPointOut,
  });
}

class DataSink extends FbdObjectBase {
  final ConnectionPointIn connectionPointIn;
  DataSink({
    required super.documentation,
    required super.addData,
    required this.connectionPointIn,
  });
}

class Jump extends FbdObjectBase {
  final ConnectionPointIn connectionPointIn;
  Jump({
    required super.documentation,
    required super.addData,
    required this.connectionPointIn,
  });
}

class LeftPowerRail extends LdObjectBase {
  final List<ConnectionPointOut>? connectionPointOuts;
  LeftPowerRail({
    required super.documentation,
    required super.addData,
    this.connectionPointOuts,
  });
}

class RightPowerRail extends LdObjectBase {
  final List<ConnectionPointIn>? connectionPointIns;
  RightPowerRail({
    required super.documentation,
    required super.addData,
    this.connectionPointIns,
  });
}

class Coil extends LdObjectBase {
  final ConnectionPointIn connectionPointIn;
  final ConnectionPointOut connectionPointOut;
  Coil({
    required super.documentation,
    required super.addData,
    required this.connectionPointIn,
    required this.connectionPointOut,
  });
}

class Contact extends LdObjectBase {
  final ConnectionPointIn connectionPointIn;
  final ConnectionPointOut connectionPointOut;
  Contact({
    required super.documentation,
    required super.addData,
    required this.connectionPointIn,
    required this.connectionPointOut,
  });
}

class ConnectionPointIn extends IdentifiedObjectBase {
  final List<Connection>? connections;
  ConnectionPointIn({
    required super.documentation,
    required super.addData,
    this.connections,
  });
}

class Connection extends IdentifiedObjectBase {
  final int refConnectionPointOutId;
  Connection({
    required super.documentation,
    required super.addData,
    required this.refConnectionPointOutId,
  });
}

class ConnectionPointOut extends IdentifiedObjectBase {
  final int connectionPointOutId;
  ConnectionPointOut({
    required super.documentation,
    required super.addData,
    required this.connectionPointOutId,
  });
}

class XyDecimalValue {
  final double x;
  final double y;
  XyDecimalValue({required this.x, required this.y});
}

class AddData {
  final List<Data>? data;
  AddData({this.data});
}

class Data {
  final String name;
  final HandleUnknown handleUnknown;
  Data({required this.name, required this.handleUnknown});
}

abstract class TextBase {
  TextBase();
}

class SimpleText extends TextBase {
  SimpleText();
}

enum ElementaryType { dint }

enum AccessSpecifiers { private }

enum Latch { none, set$, reset }

enum HandleUnknown { discard }

enum EdgeModifierType { none, falling, rising }
