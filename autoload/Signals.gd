extends Node

signal lesson_created(dictionary) ## NewLessonDialog -> LeftPanel
signal lesson_edited(dictionary, string) ## EditLesson -> LeftPanel
signal lesson_card_pressed(nodepath) ## lessonCard -> EditLessonDialog
signal subject_added
signal lesson_added
signal lesson_removed_from_calendar(id) ## CalendarArray -> LessonCard
signal removing_lesson_from_calendar(position, size, id)  ## [EditLessonDialog, AlertDialog, LessonCellButton] -> CalendarArray
signal lesson_added_to_calendar(nodepath)
signal deleting_lesson_from_calendar_finished # CalendarArray -> EditLessonDialog
signal lesson_cell_opened(id) ## LessonCellButton -> LeftPanel
signal program_reseted ## Header -> 
signal updating_conflicts

signal data_sent(nodepath, data, debug)

signal database_reseted(database_name) # 
signal lessons_database_updated ##
signal subjects_database_updated ## 
signal locations_database_updated
signal disciplines_database_updated
signal routes_database_updated

signal save_as_pressed ## Head ->
signal data_saved


##_______________LessonDialog_____________________
signal set_color_same_as_CM_emitted(color, lesson_name)

##______________________________
signal day_button_pressed(x, is_empty)
signal time_button_pressed(y, is_empty)


##________Affichage des fenetres de dialog_____
signal dialog_route_shown
signal dialog_new_lesson_shown
signal dialog_export_csv_shown


##_______ Messages d'erreur____________
signal error_emitted(error_name, node_path)
signal error_confirmed(error_name, node_path)
signal error_canceled(error_name, node_path)

##______ Gestion des trajets ______
signal route_deleted(location_A, location_B)
signal route_created(location_A, location_B)


##______ Système de préférences _____

signal preferences_loaded
signal preferences_shown
signal preferences_reseted
signal preferences_saving
signal preferences_saved

signal preference_number_of_columns_setted


## _______ export PNG _________
signal png_export_started
signal png_export_ended
