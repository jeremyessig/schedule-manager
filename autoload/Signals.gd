extends Node

signal lesson_created(dictionary) ## NewLessonDialog -> LeftPanel
signal lesson_edited(dictionary, string) ## EditLesson -> LeftPanel
signal lesson_card_pressed(nodepath) ## lessonCard -> EditLessonDialog
signal subject_added
signal lesson_added
signal lesson_card_deleted(id) ## EditLessonDialog -> LeftPanel
signal error_emitted(error_name, node_path)
signal lesson_removed_from_calendar(id) ## CalendarArray -> LeftPanel
signal lesson_from_calendar_deleted(position, size, id) ## [EditLessonDialog, AlertDialog, LessonCellButton] -> CalendarArray
signal deleting_lesson_from_calendar_finished # CalendarArray -> EditLessonDialog
signal lesson_cell_opened(id) ## LessonCellButton -> LeftPanel

signal data_sent(nodepath, data, debug)
