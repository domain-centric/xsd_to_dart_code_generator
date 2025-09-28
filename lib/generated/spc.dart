class Project {
  FileHeader fileHeader;
  ContentHeader contentHeader;
  Types types;
  Instances instances;
  double schemaVersion;
}

class FileHeader {
  String companyName;
  String productName;
  String productVersion;
}

class ContentHeader {
  AddDataInfo addDataInfo;
  AddData addData;
  String name;
  DateTime creationDateTime;
}

class AddDataInfo {
  List<Info>? info;
}

class Info {
  String name;
  double version;
  String vendor;
}

class Types {
  GlobalNamespace globalNamespace;
}

class GlobalNamespace extends TextualObjectBase {
  List<GlobalNamespaceItem> items;
}

class Instances {
  List<Configuration>? configuration;
}

class Configuration extends TextualObjectBase {
  List<Resource>? resource;
}

class Resource extends TextualObjectBase {
  List<VarList>? globalVars;
}

abstract class TypeSpecBase {}

abstract class InstantlyDefinableTypeSpecBase extends TypeSpecBase {}

abstract class BehaviorRepresentationBase {}

abstract class ProgrammingLanguageBase extends BehaviorRepresentationBase {}

abstract class IdentifiedObjectBase {
  TextBase documentation;
  AddData addData;
}

abstract class GraphicalObjectBase extends IdentifiedObjectBase {}

abstract class CommonObjectBase extends GraphicalObjectBase {}

abstract class FbdObjectBase extends GraphicalObjectBase {}

abstract class LdObjectBase extends GraphicalObjectBase {}

abstract class NetworkBase extends GraphicalObjectBase {
  String? label;
  int evaluationOrder;
}

abstract class TextualObjectBase extends IdentifiedObjectBase {
  String? usingDirective;
}

abstract class NamespaceContentBase extends TextualObjectBase {
  String name;
}

class UserDefinedTypeDecl extends NamespaceContentBase {
  TypeSpecBase userDefinedTypeSpec;
}

class ArrayTypeSpec extends InstantlyDefinableTypeSpecBase {
  TypeRef baseType;
  List<DimensionSpec> dimensionSpec;
  AddData addData;
}

class DimensionSpec {
  int dimensionNumber;
}

class IndexRange {
  String lower;
  String upper;
}

class EnumTypeSpec extends TypeSpecBase {
  List<Enumerator> enumerator;
  AddData addData;
}

class Enumerator {
  TextBase documentation;
  String name;
}

class EnumTypeWithNamedValueSpec extends TypeSpecBase {
  List<Enumerator> enumerator;
  ElementaryType baseType;
  AddData addData;
}

class Enumerator {
  TextBase documentation;
  String name;
  String value;
}

class StructTypeSpec extends TypeSpecBase {
  List<VariableDecl> member;
  AddData addData;
}

class Function$ extends NamespaceContentBase {
  TypeRef resultType;
  ParameterSet parameters;
  List<ExternalVarList>? externalVars;
  List<VarList>? tempVars;
  BodyWithoutSFC mainBody;
}

class ParameterSet {
  List<ParameterSetItem> items;
}

class Variable extends VariableDecl {
  int orderWithinParamSet;
}

class Variable extends VariableDecl {
  int orderWithinParamSet;
  EdgeModifierType edgeDetection;
}

class Variable extends VariableDecl {
  int orderWithinParamSet;
}

class VarListWithAccessSpec extends VarList {
  AccessSpecifiers accessSpecifier;
}

class Body extends TextualObjectBase {
  List<BehaviorRepresentationBase> bodyContent;
}

class BodyWithoutSFC extends TextualObjectBase {
  List<ProgrammingLanguageBase> bodyContent;
}

class VarList extends TextualObjectBase {
  List<VariableDecl>? variable;
}

class ExternalVarList extends TextualObjectBase {
  List<VariableDeclPlain>? variable;
}

class VariableDecl extends VariableDeclPlain {
  Value initialValue;
  AddressExpression address;
}

class VariableDeclPlain extends TextualObjectBase {
  TypeRef type;
}

class TypeRef {
  TypeRefItem item;
}

class Value {
  ValueItem item;
}

class ArrayValue {
  Value value;
}

class Value extends Value {
  String? repetitionValue;
}

class Value extends Value {
  String member;
}

class AddressExpression extends FixedAddressExpression {}

class FixedAddressExpression extends TextualObjectBase {
  String? address;
}

class ST extends ProgrammingLanguageBase {
  String sT;
}

class LD extends ProgrammingLanguageBase {
  List<LadderRung>? rung;
}

class LadderRung extends NetworkBase {
  List<LadderRungItem> items;
}

class Comment extends CommonObjectBase {
  TextBase content;
}

class Block extends FbdObjectBase {
  InOutVariables inOutVariables;
  InputVariables inputVariables;
  OutputVariables outputVariables;
}

class InOutVariables {
  List<InOutVariable>? inOutVariable;
}

class InOutVariable extends IdentifiedObjectBase {
  ConnectionPointIn connectionPointIn;
  ConnectionPointOut connectionPointOut;
}

class InputVariables {
  List<InputVariable>? inputVariable;
}

class InputVariable extends IdentifiedObjectBase {
  ConnectionPointIn connectionPointIn;
}

class OutputVariables {
  List<OutputVariable>? outputVariable;
}

class OutputVariable extends IdentifiedObjectBase {
  ConnectionPointOut connectionPointOut;
}

class DataSource extends FbdObjectBase {
  ConnectionPointOut connectionPointOut;
}

class DataSink extends FbdObjectBase {
  ConnectionPointIn connectionPointIn;
}

class Jump extends FbdObjectBase {
  ConnectionPointIn connectionPointIn;
}

class LeftPowerRail extends LdObjectBase {
  List<ConnectionPointOut>? connectionPointOut;
}

class RightPowerRail extends LdObjectBase {
  List<ConnectionPointIn>? connectionPointIn;
}

class Coil extends LdObjectBase {
  ConnectionPointIn connectionPointIn;
  ConnectionPointOut connectionPointOut;
}

class Contact extends LdObjectBase {
  ConnectionPointIn connectionPointIn;
  ConnectionPointOut connectionPointOut;
}

class ConnectionPointIn extends IdentifiedObjectBase {
  List<Connection>? connection;
}

class Connection extends IdentifiedObjectBase {
  int refConnectionPointOutId;
}

class ConnectionPointOut extends IdentifiedObjectBase {
  int connectionPointOutId;
}

class XyDecimalValue {
  double x;
  double y;
}

class AddData {
  List<Data>? data;
}

class Data {
  String name;
  handleUnknown handleUnknown;
}

abstract class TextBase {}

class SimpleText extends TextBase {}

/// Common interface for: NamespaceDecl, DataTypeDecl, Program, FunctionBlock, Function
abstract class GlobalNamespaceItem {}

class Program extends NamespaceContentBase implements GlobalNamespaceItem {
  List<ExternalVarList>? externalVars;
  List<VarListWithAccessSpec>? vars;
  Body mainBody;
}

/// Common interface for: NamespaceDecl, DataTypeDecl, FunctionBlock, Function
abstract class NamespaceDeclItem {}

class FunctionBlock extends NamespaceContentBase implements NamespaceDeclItem {
  ParameterSet parameters;
  List<ExternalVarList>? externalVars;
  List<VarListWithAccessSpec>? vars;
  Body mainBody;
}

class NamespaceDecl extends NamespaceContentBase
    implements GlobalNamespaceItem, NamespaceDeclItem {
  List<NamespaceDeclItem> items;
}

/// Common interface for: InoutVars, InputVars, OutputVars
abstract class ParameterSetItem {}

class InoutVars implements ParameterSetItem {
  List<Variable>? variable;
}

class InputVars implements ParameterSetItem {
  List<Variable>? variable;
  bool? retain;
  bool? non_retain;
}

class OutputVars implements ParameterSetItem {
  List<Variable>? variable;
  bool? retain;
  bool? non_retain;
}

/// Common interface for: TypeName, InstantlyDefinedType
abstract class TypeRefItem {}

/// Common interface for: SimpleValue, ArrayValue, StructValue
abstract class ValueItem {}

class SimpleValue implements ValueItem {
  String? value;
}

class StructValue implements ValueItem {
  Value value;
}

/// Common interface for: CommonObject, LdObject, FbdObject
abstract class LadderRungItem {}

class GlobalVars extends VarList {}

class Documentation extends TextBase {}

class UserDefinedTypeSpec extends TypeSpecBase {}

class BaseType extends TypeRef {}

class Documentation extends TextBase {}

class BaseType extends ElementaryType {}

class Documentation extends TextBase {}

class Member extends VariableDecl {}

class ResultType extends TypeRef {}

class Parameters extends ParameterSet {}

class ExternalVars extends ExternalVarList {}

class TempVars extends VarList {}

class MainBody extends BodyWithoutSFC {}

class EdgeDetection extends EdgeModifierType {}

class AccessSpecifier extends AccessSpecifiers {}

class BodyContent extends BehaviorRepresentationBase {}

class BodyContent extends ProgrammingLanguageBase {}

class Variable extends VariableDecl {}

class Variable extends VariableDeclPlain {}

class InitialValue extends Value {}

class Address extends AddressExpression {}

class Type extends TypeRef {}

class InstantlyDefinedType extends InstantlyDefinableTypeSpecBase {}

class Rung extends LadderRung {}

class Content extends TextBase {}

class ExternalVars extends ExternalVarList {}

class Vars extends VarListWithAccessSpec {}

class MainBody extends Body {}

class Parameters extends ParameterSet {}

class ExternalVars extends ExternalVarList {}

class Vars extends VarListWithAccessSpec {}

class MainBody extends Body {}

enum ElementaryType { dINT }

enum AccessSpecifiers { private }

enum Latch { none, set$, reset }

enum HandleUnknown { discard }

enum EdgeModifierType { none, falling, rising }
