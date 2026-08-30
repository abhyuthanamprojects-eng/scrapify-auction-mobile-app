import 'package:equatable/equatable.dart';

enum RfxQuestionType {
  text,
  number,
  boolean,
  dropdown,
  multiSelect,
  fileAttachment;

  String get label => switch (this) {
        text => 'Text Response',
        number => 'Numeric Value',
        boolean => 'Yes / No',
        dropdown => 'Single Selection',
        multiSelect => 'Multiple Selection',
        fileAttachment => 'File / Certificate Upload',
      };
}

class RfxQuestion extends Equatable {
  final String id;
  final String section;
  final String questionText;
  final RfxQuestionType type;
  final bool isRequired;
  final List<String> options;
  final String? responseText;
  final double? responseNumber;
  final bool? responseBool;
  final List<String> selectedOptions;
  final String? attachmentUrl;

  const RfxQuestion({
    required this.id,
    required this.section,
    required this.questionText,
    required this.type,
    this.isRequired = true,
    this.options = const [],
    this.responseText,
    this.responseNumber,
    this.responseBool,
    this.selectedOptions = const [],
    this.attachmentUrl,
  });

  bool get isAnswered {
    switch (type) {
      case RfxQuestionType.text:
        return responseText != null && responseText!.trim().isNotEmpty;
      case RfxQuestionType.number:
        return responseNumber != null;
      case RfxQuestionType.boolean:
        return responseBool != null;
      case RfxQuestionType.dropdown:
        return responseText != null && responseText!.isNotEmpty;
      case RfxQuestionType.multiSelect:
        return selectedOptions.isNotEmpty;
      case RfxQuestionType.fileAttachment:
        return attachmentUrl != null && attachmentUrl!.isNotEmpty;
    }
  }

  RfxQuestion copyWith({
    String? responseText,
    double? responseNumber,
    bool? responseBool,
    List<String>? selectedOptions,
    String? attachmentUrl,
  }) =>
      RfxQuestion(
        id: id,
        section: section,
        questionText: questionText,
        type: type,
        isRequired: isRequired,
        options: options,
        responseText: responseText ?? this.responseText,
        responseNumber: responseNumber ?? this.responseNumber,
        responseBool: responseBool ?? this.responseBool,
        selectedOptions: selectedOptions ?? this.selectedOptions,
        attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      );

  @override
  List<Object?> get props => [id, responseText, responseNumber, responseBool, selectedOptions, attachmentUrl];
}

class RfxPackage extends Equatable {
  final String id;
  final String auctionCode;
  final String title;
  final String buyerName;
  final String submissionDeadline;
  final List<RfxQuestion> questions;
  final bool isSubmitted;
  final String? submittedAt;
  final double? technicalScore;

  const RfxPackage({
    required this.id,
    required this.auctionCode,
    required this.title,
    required this.buyerName,
    required this.submissionDeadline,
    required this.questions,
    this.isSubmitted = false,
    this.submittedAt,
    this.technicalScore,
  });

  int get totalQuestions => questions.length;
  int get answeredQuestions => questions.where((q) => q.isAnswered).length;
  double get progressPercentage => totalQuestions == 0 ? 0 : answeredQuestions / totalQuestions;

  @override
  List<Object?> get props => [id, auctionCode, isSubmitted, answeredQuestions];
}
