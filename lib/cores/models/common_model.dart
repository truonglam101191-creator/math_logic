abstract class CommonModel {
  late bool isDel;
  late DateTime? deleteData;
  late bool isSelect;
  late bool isEdit;
  late bool isNew;
  late bool isPin;
  late bool isFav;
  late bool isImp;

  CommonModel(
      {this.isDel = false,
      this.deleteData,
      this.isSelect = false,
      this.isEdit = false,
      this.isNew = false,
      this.isFav = false,
      this.isImp = false,
      this.isPin = false});
}
