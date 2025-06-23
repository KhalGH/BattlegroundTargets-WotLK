-- -------------------------------------------------------------------------- --
-- BattlegroundTargets ruRU Localization (by Каапи@Черный Шрам)               --
-- Please make sure to save this file as UTF-8. ¶                             --
-- -------------------------------------------------------------------------- --
if GetLocale() ~= "ruRU" then return end
BattlegroundTargets_Localization:CreateLocaleTable({
["Open Configuration"] = "Открыть настройки",

["Configuration"] = "Настройки",
["10 vs 10"] = "10 на 10",
["15 vs 15"] = "15 на 15",
["40 vs 40"] = "40 на 40",
["Enable"] = "Включить",
["Independent Positioning"] = "Независимое позиционирование",
["Layout"] = true,
["Summary"] = true,
["Copy this settings to '%s'"] = "Копировать эти настройки в '%s'",
["Show Role"] = true,
["Show Specialization"] = "Отображать специализацию",
["Show Class Icon"] = "Отображать иконку класса",
["Hide Realm"] = "Не отображать сервер",
["Show Leader"] = "Отображать лидера",
["Show Healer"] = "Отображать хилов",
["Show Guild Groups"] = true,
["Show Target"] = "Отображать цель",
["Show Focus"] = "Отображать фокус",
["Show Flag Carrier"] = "Отображать флагоносца",
["Show Main Assist Target"] = "Отображать главного наводчика",
["Show Target Count"] = "Отображать подсчет нацеливаний",
["Show Health Bar"] = "Отображать полоску здоровья",
["Show Percent"] = "Отображать проценты здоровья",
["Show Range"] = "Отображать расстояние",
 ["This option uses the CombatLog to check range."] = true,
 ["This option uses a pre-defined spell to check range:"] = "Эта опция использует выбранное заклинание для проверки расстояния:",
 ["Mix"] = true,
 ["if you are attacked only"] = true,
 ["(class dependent)"] = true,
 ["Disable this option if you have CPU/FPS problems in combat."] = "Отключить эту опцию, если у вас есть проблемы с производительностью в бою.",
["Sort By"] = "Сортировать по",
["Text Size"] = "Размер шрифта",
["Scale"] = "Масштаб",
["Width"] = "Ширина",
["Height"] = "Высота",

["General Settings"] = "Общие настройки",
["Show Minimap-Button"] = "Отображать кнопку на мини-карте",

["click & move"] = "Нажмите & перемещайте",
["BattlegroundTargets does not update if this Tab is opened."] = "BattlegroundTargets не обновляет информацию если эта вкладка открыта.",

["Close Configuration"] = "Закрыть настройки",
["Show roles on the right"] = "Роли справа",
["Show roles on the left"]  = "Роли слева",
["Don't show roles"]        = "Не показывать роли",

["Available commands:"] = "Доступные команды",
["To log healer detections while you are in a BG."] = "Показывать сообщения о детектах хилов на БГ",
["To enable permanent healer detection mode while you are in BG. After that, you don't need to enter /bgt hdlog every time"] = "Постоянно показывать сообщения о детектах хилов на бг. После включения данной опции, не нужно прописывать команду '/bgt hdlog' каждый раз при заходе в игру.",
["To show full info about all healers detects."] = "Показать полный отчет о текущих детектах. Работает только на БГ.",
["GET or SET (if the number exists) retention period of the data in months, after which the obsolete data about healer will be deleted. If <number> is set up to 0 then DataBase will be disabled."] = "ПОЛУЧИТЬ или УСТАНОВИТЬ (если указанно <число>) срок хранения данных в БД о хилах (в месяцах). По истечению указанного периода данные будут удаляться. Минимальный срок хранения: 1 мес. Максимальный: 11. Значение 0 -- отключит базу данных.",

 ["Logging of healers detection is enabled.\nType |cff55c912/bgt hdlog|r again to disable."] = "Включенны оповещения срабатывающие при обнаружении хилов. Еще раз введите |cff55c912/bgt hdlog|r чтобы отключить."
, ["Logging of healers detection is disabled."] = "Оповещения срабатывающие при обнаружении хилов теперь выключенны."
, ["Something is wrong! Not possible to prepare info for the report. The option: 'Show roles' should be enabled. Or try to get report later."] = "Что-то не так! Не возможно собрать отчет. Опция 'Показывать роли' должна быть включенна, или попробуйте получить отчет позднее."
, ["You should be in some battleground to call reports."] = "Вы долюны быть на БГ, чтобы получить отчет."
, ["Unable to set this period. You must use values in the range of 0 to 11."] = "Невозможно установить период. Значения должны находится в диапазоне от 0 до 11 (включительно) мес."
, ["Healers data will now be deleted from the database after "] = "Данные о хилах теперь будут удаляться через " , ["months. You need to re-login to save settings."] = "мес. Перезайдите на персонажа (relog) чтобы сохранить изменения."
, ["Current storage period of data is: "] = "Текущий срок хранения данных: ", [" months. Max period is 11 months."] = " мес. Максимальный период: 11 месяцев."
, ["Permanent logging of healers detection is enabled. Type |cff55c912/bgt hdlogAlways|r again to disable."] = "Включенны постоянные оповещения срабатывающие при обнаружении хилов. Введите |cff55c912/bgt hdlogAlways|r для отключения."
, ["Permanent logging of healers detection is disabled."] = "Постоянное логирование обнаружений отключенно."
, ["[Warning]: To use that command you have to pick 'Show roles' option in the settings panel of BattlegroundTargets."] = "[Внимание]: Для использования данной команды должна быть выбранна опция 'Показывать роли' на панели настроек  BattlegroundTargets"
, ["DB is disabled. You need to re-login to save settings."] = "База данных отключена. Пожалуйста перезайдите на персонажа чтобы сохранить изменения!"

})
