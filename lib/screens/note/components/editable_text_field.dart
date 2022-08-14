import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditableTextField extends StatefulWidget {
  late Note note;
  EditableTextField({Key? key, required Note this.note}) : super(key: key);

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  bool _isEditingText = false;
  double defaultSize = SizeConfig.defaultSize;
  final int _maxLength = 25;
  late int _textLength;
  late TextEditingController _editingController;
  late String initialText = widget.note.memo;

  @override
  void initState() {
    super.initState();
    this._editingController = TextEditingController(text: initialText);
    this._textLength = initialText.length;
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _editableTextField();
  }

  Widget _editableTextField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          Text(
            "한줄 메모",
            style: TextStyle(
                color: kPrimaryWhiteColor,
                fontSize: defaultSize * 1.5,
                fontWeight: FontWeight.w600),
          ),
          Spacer(),
          if (_isEditingText == true)
            Text(
              "${_textLength}/${_maxLength}",
              style: TextStyle(color: kMainColor),
            )
        ],
      ),
      SizedBox(height: defaultSize),
      Container(
          padding: EdgeInsets.only(left: defaultSize),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: kPrimaryGreyColor),
          child: _isEditingText == true
              ? TextField(
                  textAlignVertical: TextAlignVertical.center,
                  autofocus: true,
                  controller: _editingController,
                  maxLength: _maxLength,
                  cursorColor: kMainColor,
                  style: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontSize: defaultSize * 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _textLength = value.length;
                    });
                  },
                  decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      suffixIcon: TextButton(
                        child: Text(
                          "저장",
                          style: TextStyle(color: kMainColor),
                        ),
                        onPressed: () {
                          //!event: 곡 상세정보 뷰 - 메모 수정
                          Analytics_config()
                              .noteDetailViewMemo(widget.note.tj_title);
                          setState(() {
                            initialText = _editingController.text;
                            _isEditingText = false;
                            Provider.of<NoteData>(context, listen: false)
                                .editNote(widget.note, initialText);
                          });
                        },
                      )),
                )
              : InkWell(
                  onTap: () {
                    setState(() {
                      _isEditingText = true;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                          initialText.isEmpty ? "메모를 입력해 주세요" : initialText,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontSize: defaultSize * 1.4,
                            fontWeight: FontWeight.w400,
                          )),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditingText = true;
                          });
                        },
                        color: kPrimaryWhiteColor,
                        icon: Icon(Icons.edit),
                      )
                    ],
                  ),
                ))
    ]);
  }
}
