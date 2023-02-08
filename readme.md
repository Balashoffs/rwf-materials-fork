Chapter 7 - Routing and navigation
Use navigator 2.0 with package Routemaster.

Populate navigator package:
name                        like    points  popularity  link
auto_route: ^5.0.4          2107    130     99          https://pub.dev/packages/auto_route
beamer: ^1.5.3              962     140     97          https://pub.dev/packages/beamer
routemaster: ^1.0.1         511     130     96          https://pub.dev/packages/routemaster
qlevar_router: ^1.7.1       111     140     90          https://pub.dev/packages/qlevar_router
yeet: ^0.4.10               83      130     42          https://pub.dev/packages/yeet
fluro: ^2.0.4               771     140     98          https://pub.dev/packages/fluro
navigation_manager: ^1.2.1  2       0       0           https://pub.dev/packages/navigation_manager

* auto_route — позволяет использовать кодогенерацию для конфигурации набора роутов, поддерживает вложенную навигацию; можно использовать как именованную навигацию через пути, так и через классы роутов;
* Beamer — предлагает интересную концепцию с разделением навигации по приложению на отдельные "разделы", у каждого из которых свой обработчик;
* Routemaster — небольшая аккуратная библиотека для навигации по URL. Можно посмотреть реализацию, чтобы понять концепцию работы с новыми компонентами;
* qlevar_router — умеет работать с многослойной навигацией, предоставляет из коробки методы для отображения диалогов и overlay;
* yeet — позволяет использовать паттерны в URL для описания параметров, предоставляет свой взгляд на вложенную навигацию;
* fluro — дает возможность использовать обработчики путей в виде функций вместо роутов;
* navigation_manager — есть поддержка uri-паттернов, используется концепция поддеревьев (sub-tree) и Duplicate strategies, как в Android Activity (в разработке).