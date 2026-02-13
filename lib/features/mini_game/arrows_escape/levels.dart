import 'models/arrow_model.dart';

class ArrowCell {
  const ArrowCell(this.direction, {this.hasHead = false});

  final ArrowDirection direction;
  final bool hasHead;
}

class LevelData {
  final List<List<ArrowCell?>> grid;

  const LevelData(this.grid);

  int get rows => grid.length;
  int get cols => grid.isEmpty ? 0 : grid.first.length;
}

const List<LevelData> kArrowEscapeLevels = [
  LevelData([
    [
      ArrowCell(ArrowDirection.up, hasHead: true),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right, hasHead: true),
      ArrowCell(ArrowDirection.down),
    ],
    [
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.left, hasHead: true),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.down),
    ],
    [
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right, hasHead: true),
      ArrowCell(ArrowDirection.down),
    ],
    [
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.left, hasHead: true),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.down),
    ],
    [
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right, hasHead: true),
      ArrowCell(ArrowDirection.down),
    ],
    [
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.left, hasHead: true),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.down),
    ],
    [
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right, hasHead: true),
      ArrowCell(ArrowDirection.down, hasHead: true),
    ],
  ]),
  LevelData([
    [
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right, hasHead: true),
    ],
    [
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right),
      ArrowCell(ArrowDirection.right, hasHead: true),
    ],
    [
      ArrowCell(ArrowDirection.up, hasHead: true),
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.up),
    ],
    [
      ArrowCell(ArrowDirection.down),
      ArrowCell(ArrowDirection.down),
      ArrowCell(ArrowDirection.down),
      ArrowCell(ArrowDirection.down),
      ArrowCell(ArrowDirection.down),
      ArrowCell(ArrowDirection.down),
      ArrowCell(ArrowDirection.down, hasHead: true),
    ],
    [
      ArrowCell(ArrowDirection.left, hasHead: true),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
    ],
    [
      ArrowCell(ArrowDirection.left, hasHead: true),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
      ArrowCell(ArrowDirection.left),
    ],
    [
      ArrowCell(ArrowDirection.up, hasHead: true),
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.up),
      ArrowCell(ArrowDirection.up),
    ],
  ]),
];
