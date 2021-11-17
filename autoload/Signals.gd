extends Node

signal lesson_created(dictionary) ## NewLessonDialog -> LeftPanel
signal lesson_edited(dictionary, string) ## EditLesson -> LeftPanel
signal lesson_card_pressed(nodepath) ## lessonCard -> EditLessonDialog
signal subject_added
signal lesson_added
signal error_emitted(error_name, node_path)
signal lesson_removed_from_calendar(id) ## CalendarArray -> LessonCard
signal removing_lesson_from_calendar(position, size, id) ## [EditLessonDialog, AlertDialog, LessonCellButton] -> CalendarArray
signal deleting_lesson_from_calendar_finished # CalendarArray -> EditLessonDialog
signal lesson_cell_opened(id) ## LessonCellButton -> LeftPanel
signal program_reseted ## Header -> 

signal data_sent(nodepath, data, debug)

signal database_reseted(database_name) # 
signal lessons_database_updated ##
signal subjects_database_updated ## 
signal locations_database_updated
signal disciplines_database_updated
signal distances_list_updated

signal save_as_pressed ## Head ->
