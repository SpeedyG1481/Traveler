import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:traveler/data/images.dart';

class MegaDropdown<T> extends StatelessWidget {
  final Mode mode;
  final bool showSelectedItem;
  final DropdownSearchBuilder<T> dropdownBuilder;
  final Widget dropDownButton;
  final double contentPadding;
  final Color textColor;
  final List<T> items;
  final String hint;
  final ValueChanged<T> onChanged;
  final T selectedItem;
  final bool showSearchBox;
  final bool showAsSuffixIcons;
  final InputDecoration searchBoxDecoration;

  MegaDropdown({
    this.mode,
    this.dropdownBuilder,
    this.showSelectedItem = true,
    this.dropDownButton,
    this.contentPadding,
    this.textColor = Colors.white,
    this.items,
    this.hint,
    this.onChanged,
    this.selectedItem,
    this.searchBoxDecoration,
    this.showSearchBox = false,
    this.showAsSuffixIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Images.bigButton,
          fit: BoxFit.fill,
        ),
      ),
      child: DropdownSearch(
        mode: this.mode,
        showAsSuffixIcons: this.showAsSuffixIcons,
        showSelectedItem: this.showSelectedItem,
        dropdownBuilder: this.dropdownBuilder,
        dropDownButton: this.dropDownButton,
        showSearchBox: this.showSearchBox,
        searchBoxDecoration: this.searchBoxDecoration,
        dropdownSearchBaseStyle: TextStyle(
          fontSize: 13.5,
          color: this.textColor,
          fontWeight: FontWeight.w500,
        ),
        dropdownSearchDecoration: InputDecoration(
          contentPadding: EdgeInsets.all(this.contentPadding),
          enabledBorder: InputBorder.none,
          errorMaxLines: 1,
          errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          labelStyle: TextStyle(
            fontSize: 13.5,
            color: this.textColor,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            fontSize: 13.5,
            color: this.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        items: this.items,
        hint: this.hint,
        onChanged: this.onChanged,
        selectedItem: this.selectedItem,
      ),
    );
  }
}
