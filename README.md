# Привет!


Чтобы связать свой симулятор X-Plane и Пронебо по локальной сети, тебе потребуется:
1. Скачать и установить плагин [FlyWithLua](https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/) в свой симулятор. В подкаталог *X:/X-Plane/Resourses/Plugins/FlyWithLua/Scripts/* скопируй файл NMEA_.lua
2. Скачать [Пронебо](https://vk.com/market-159833375?screen=group&w=product-159833375_4769933) на свой смартфон. PS. Версия 7.3 работает стабильнее с внешними источниками данных, но плюсы 7.4 перекрывают эту особенность 
3. В приложении Пронебо заходи в Настройки => Настройки ГлоНаСС / GPS => Внешний GPS и бародатчик => TCP/UDP IP: *IP адрес компьютер*, порт *10110* => Сохранить. В версии 7.4 отключи автоматическое соединение с внешним GPS!
4. Запускай X-Plane и загружайся в аэропорту, запускай NMEA2TCP.exe
5. Обязательным условием для Пронебо 7.4 наличие запущенного полёта (присутствие на стоянке) в X-Plane. В окне ГлоНаСС / GPS в верхнем левом углу нажимай три точки => Вид карты => Подключить GPS => UDP/TCP GPS
6. Проверь в NMEA2TCP.exe, что Пронебо соединилось и приложению исправно отправляются NMEA данные (раз в секунду)

## Особенности работы
- Если при запуске Пронебо не происходит подключение в течение 19 секунд (в окне NMEA2TCP.exe с обрывами отправляются NMEA), то Пронебо следует принудительно остановить через настройки приложений Андроида и снова запустить  
- При разрыве соединения, допустим закрыли Пронебо или NMEA2TCP.exe, соединение восстанавливается без проблем
 

## Известные проблемы
Если используешь Пронебо 7.4 - обязательно сделай бэкап настроек и отключи автоматическое соединение с внешним GPS (Если установить тумблер, при этом отсутствует связь с источником данных, то приложение виснет без возможности зайти в настройки. Спасёт сброс кэша). В 7.3 такой проблемы не замечено

## Переходные положения
Программа с аналогичным функционалом для MSFS2020 [*click*](https://github.com/mihai-dinculescu/msfs-2020-gps-link)
