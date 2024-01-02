import 'dart:math';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/Presentation/UIUtilities/ui_utilities.dart';
import 'package:gap/gap.dart';

/// [SideMenuView] permette di creare una vista con menu a scorrimento
/// laterale, dove a scorrere è la pagina visualizzata [ContentVisualizer].
/// La pagina scorrendo lascerà spazio al set di pulsanti [SideMenuButton]
/// del menu [SideMenu]. Questi saranno divisi in gruppi [SideMenuGroup]
/// ognuno con un titolo.
/// 
/// Mette a disposizione [SideMenuViewInherited] che permette a tutti i discendenti
/// di comunicare con il menu, potendolo aprire e chiudere, o ricavare informaizoni
/// sul suo stato.
/// 
/// [initialContentIndex] indica tra i pulsanti presenti che possiede un contenuto
/// da visualizzare, l'indice di quello da visualizzare inizialmente.
/// 
/// [rotate3D], inoltre, è un flag che attiva o disattiva la rotazione tridimensionale
/// della pagina in movimento.
/// 
/// [topBarActionWidget] permette di specificare un widget che verrà visualizzato
/// a lato sulla top bar [ContentVisualizerTopBar].

class SideMenuView extends StatefulWidget{
  final int initialContentIndex;
  final List<SideMenuGroup> groups;
  final bool rotate3D;
  final bool overrideMediaQuery;
  final bool showTopBarOnHorizontalView;
  final Widget? topBarActionWidget;
  final double contentBorderRadius;

  const SideMenuView({
    super.key,
    required this.groups,
    this.initialContentIndex = 0,
    this.rotate3D = true,
    this.overrideMediaQuery = true,
    this.showTopBarOnHorizontalView = false,
    this.topBarActionWidget,
    this.contentBorderRadius = 10
  });

  @override
  State<SideMenuView> createState() => _SideMenuViewState();
}

class _SideMenuViewState extends State<SideMenuView> 
  with SingleTickerProviderStateMixin{  

  final double buttonFractionScaleDown = 1/3;
  final double rotation3dAngle = pi/7;

  SideMenuButton? lastActive;

  AnimationController? _controller;
  late Animation<double> animation;

  GlobalKey<_ContentVisualizerState> contentKey = GlobalKey(); 

  double _textWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text, 
        style: style
      ), 
      maxLines: 1, 
      textDirection: TextDirection.ltr
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  // Controlla che la pagina correntemente visualizzata
  // esista ancora.
  double scaleDownPercentage()
  {
    double largerButtonNameWidth = widget.groups.expand(
      (element) => element.buttons,
    ).map((e) => _textWidth(e.name, Theme.of(context).textTheme.bodyMedium!)).reduce(max);


    return buttonFractionScaleDown * (largerButtonNameWidth + SideMenuButton.iconSize + 15) 
    / (MediaQuery.of(context).size.width);
  } 

  // Controlla che la pagina correntemente visualizzata
  // esista ancora.
  bool currentPageStillExists()
  {
    return widget.groups.any((group) => 
      group.buttons.any((button) => button.content == lastActive!.content)
    );
  } 

  // ricerca tra i pulsanti il pulsante con contenuti che corrisponde
  // all'indice indicato
  void checkAndFetchContent()
  {
    // Controlla che non ci siano più pulsanti con lo stesso nome
    Map<String, int> namesOccurrences = {};
    for(SideMenuGroup group in widget.groups){ 
      for(SideMenuButton button in group.buttons)
      {
        if(namesOccurrences.containsKey(button.name))
        {
          throw Exception(
            "Can't have more buttons with the same name: "
            "${button.name}"
          );
        }
        else{
          namesOccurrences[button.name] = 1;
        }
      }
    }

    // Init content
    int initialContentIndex = widget.initialContentIndex;

    SideMenuButton? buttonWithContent;

    widget.groups.firstWhere((group) {
      try{
        buttonWithContent = group.buttons.firstWhere(
          (element) {
            if(element.content != null)
            {
              initialContentIndex --;
              return initialContentIndex < 0;
            }
            else {
              return false;
            }
          }
        );
      }
      catch(e){
        throw Exception(
          "No content found at index ${widget.initialContentIndex}. "
          "At least ${widget.initialContentIndex + 1} "
          "button${widget.initialContentIndex != 0? "s":""} should have content to visualize."
        );
      }
      
      return true;
    });

    changeState(buttonWithContent);
  }

  // Cambia lo stato e quindi la pagina visualizzata dal menu
  void changeState(SideMenuButton? newButton)
  {
    setState(() {
      lastActive = newButton;
      if(isOpened())
      {
        _controller!.reverse();
      }
    });
  }

  bool isWithTopBarMode()
  {
    return  !UIUtilities.isHorizontal(context) || widget.showTopBarOnHorizontalView;
  }

  @override
  void initState() {
    super.initState();   

    checkAndFetchContent();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
      if(mounted)setState(() {});
    });

    animation = Tween<double>(begin: 0, end: 1).animate(_controller!);    
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool isOpened()
  {
    return _controller != null && _controller?.value != 0 ;
  }

  void close()
  {
    _controller?.reverse();
  }

  void open()
  {
    _controller?.forward();
  }

  @override
  Widget build(BuildContext context) {    

    if(isOpened() && UIUtilities.isHorizontal(context))
    {
      close();
    }

    if(!currentPageStillExists())
    {
      checkAndFetchContent();
    }

    double scaledWidth = (1 - scaleDownPercentage()) 
    * MediaQuery.of(context).size.width ;

    double menuLeftPositionOpened = 20 + (MediaQuery.of(context).size.width -
    scaledWidth) / buttonFractionScaleDown;

    if(widget.rotate3D && isWithTopBarMode())
    {
      menuLeftPositionOpened -= (scaledWidth - scaledWidth * cos(rotation3dAngle))/1.5;
    }

    double? left = isWithTopBarMode()?
                  menuLeftPositionOpened * animation.value : null;
    double? right = isWithTopBarMode()?
                  null:0;

    double? width = isWithTopBarMode()?
                  MediaQuery.of(context).size.width : 
                  MediaQuery.of(context).size.width - menuLeftPositionOpened - 20;

    return PopScope(
      canPop: animation.value == 0,
      onPopInvoked: (didPop) {
        if(!didPop && isOpened())
        {
          close();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SideMenuViewInherited(
            opened: isOpened(),
            topBarActionWidget: widget.topBarActionWidget,
            isWithTopBarMode: isWithTopBarMode(),
            onCloseRequest: close,
            onOpenRequest: open,
            onChangePageRequest: (state) => changeState(state),
            lastActive: lastActive,
            content: lastActive?.content ?? Container(),
            child: Stack(
              children: [
                SideMenu(
                  groups: widget.groups
                ),
                Positioned(
                  left: left,
                  right: right,
                  top: 0,
                  width: width,
                  height: MediaQuery.of(context).size.height-
                          MediaQuery.of(context).padding.top,
                  child: Transform.scale(
                    alignment: Alignment.center,
                    scale: isWithTopBarMode()?
                    1 - scaleDownPercentage() * animation.value : 1,
                    child: Transform(
                      transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0005)
                      ..rotateY(widget.rotate3D? rotation3dAngle * animation.value : 0),
                      alignment: Alignment.center,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          size: Size(
                            widget.overrideMediaQuery?
                            width:
                            MediaQuery.of(context).size.width, 
                            isWithTopBarMode() &&  widget.overrideMediaQuery? 
                              MediaQuery.of(context).size.height - 
                              ContentVisualizerTopBar.barHeight:
                              
                              MediaQuery.of(context).size.height
                          ) 
                        ),
                        child: ContentVisualizer(
                          animation: animation,
                          borderRadius: widget.contentBorderRadius,
                          onMenuButton: (){
                            if(isOpened())
                            {
                              close();
                            }
                            else{
                              open();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }  
}

/// [SideMenuViewInherited] permette a tutti i discendenti
/// di [SideMenuView] di comunicare con il menu, potendolo aprire e chiudere, 
/// o ricavare informaizoni sul suo stato.

class SideMenuViewInherited extends InheritedWidget{   

  final SideMenuButton? lastActive;
  final Widget? topBarActionWidget;
  final Widget content;
  final bool opened;
  final bool isWithTopBarMode;
  final VoidCallback onCloseRequest;
  final VoidCallback onOpenRequest;
  final void Function(SideMenuButton? button) _onChangeStateRequest;


  const SideMenuViewInherited({
    super.key, 
    this.lastActive,
    required this.isWithTopBarMode,
    required this.topBarActionWidget,
    required this.content,
    required this.opened,
    required this.onCloseRequest,
    required this.onOpenRequest,
    required void Function(SideMenuButton? button) onChangePageRequest,
    required super.child,
  }): _onChangeStateRequest = onChangePageRequest;
  

  static SideMenuViewInherited? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SideMenuViewInherited>();
  }

  static SideMenuViewInherited of(BuildContext context) {
    final SideMenuViewInherited? result = _maybeOf(context);
    assert(result != null, 'No SideMenuViewInherited found in context');
    return result!;
  }

  void close() => onCloseRequest.call();
  void open() => onOpenRequest.call();
  void _changePage(SideMenuButton? state) => _onChangeStateRequest.call(state);

  @override
  bool updateShouldNotify(covariant SideMenuViewInherited oldWidget) {
    return lastActive != oldWidget.lastActive ||
    content != oldWidget.content ||
    opened != oldWidget.opened;
  }

}

/// Visualizza tutti [SideMenuGroup] 
class SideMenu extends StatelessWidget{

  final List<SideMenuGroup> groups;

  const SideMenu({
    super.key,
    required this.groups
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: SingleChildScrollView(
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(!SideMenuViewInherited.of(context).isWithTopBarMode
                  && SideMenuViewInherited.of(context).topBarActionWidget != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: ContentVisualizerTopBar.barHeight,
                        child: Material(
                          elevation: 5,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(defaultBorderRadius),
                            bottomRight: Radius.circular(defaultBorderRadius) 
                          ),
                          color: Theme.of(context).colorScheme.onPrimary,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Align(
                              child: SideMenuViewInherited.of(context).topBarActionWidget!
                            ),
                          ),
                        ),
                      ),
                      const Gap(20),
                    ],
                  ),                
                  ...groups
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

/// Visualizza tutti i [SideMenuButton] al suo interno  un [title] in maiuscolo 
/// a capo di tutti i pulsanti del gruppo.

class SideMenuGroup extends StatelessWidget
{
  final String title;
  final List<SideMenuButton> buttons;

  const SideMenuGroup({
    super.key,
    required this.title,
    required this.buttons
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 10),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12
            ),
          ),
        ),
        const Gap(5),        
        ...buttons,
        Divider(
          height: 10,
          thickness: 0.5,
          indent: 0,
          endIndent: 0,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ],
    );
  }
}

/// Classe che rappresenta ogni pulsante del menu, permettendo all'utente
/// sia di selezionare un nuovo contenuto da visualizzare [content], sia di effettuare
/// delle azioni [onPressed].
class SideMenuButton extends StatefulWidget{
  static const double iconSize = 20;

  final String name;
  final Widget icon;
  final Widget? content;
  final VoidCallback? onPressed;

  const SideMenuButton({
    super.key,
    required this.name,
    required this.icon,
    this.content,
    this.onPressed
  });
  @override
  State<SideMenuButton> createState() => _SideMenuButtonState();
}

class _SideMenuButtonState extends State<SideMenuButton> {  
  bool _isActive = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SideMenuButton? lastActive = SideMenuViewInherited.of(context).lastActive;


    if(lastActive != null)
    {
      _isActive = lastActive.name  == widget.name;
    }
      
    return Material(
      elevation: _isActive? 2:0,
      color: !_isActive? Colors.transparent : Theme.of(context).colorScheme.onPrimary,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(defaultBorderRadius),
        bottomRight: Radius.circular(defaultBorderRadius) 
      ),
      child: InkWell(
        onTap: (){
          if(widget.content!=null)
          {            
            SideMenuViewInherited.of(context)._changePage(widget);
          }         

          widget.onPressed?.call();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 20),
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                if(widget.icon is Icon)
                Icon(
                  (widget.icon as Icon).icon,
                  size: SideMenuButton.iconSize,
                  color: !_isActive? (widget.icon as Icon).color:
                  Theme.of(context).colorScheme.primary,
                ),
                if(widget.icon is ImageIcon)
                ImageIcon(
                  (widget.icon as ImageIcon).image,
                  size: SideMenuButton.iconSize,
                  color: !_isActive? (widget.icon as ImageIcon).color:
                  Theme.of(context).colorScheme.primary,
                ),
                if(widget.icon is! Icon && widget.icon is! ImageIcon)
                widget.icon,
                const Gap(10),
                Text(
                  widget.name,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: !_isActive? Theme.of(context).colorScheme.onPrimary : 
                    Theme.of(context).colorScheme.primary,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pagina che visualizza i contenuti richiesti dai [SideMenuButton]
/// che verrà fatta scorrere all'aprirsi del menu.
/// Visualizza in alto ad ogni contenuto una topbar [ContentVisualizerTopBar]
/// che permette di accedere al menu.
class ContentVisualizer extends StatefulWidget{

  final Animation<double> animation;
  final VoidCallback onMenuButton;
  final double borderRadius;

  const ContentVisualizer({
    super.key,
    required this.animation,
    required this.onMenuButton,
    required this.borderRadius,
  });

  @override
  State<ContentVisualizer> createState() => _ContentVisualizerState();
}

class _ContentVisualizerState extends State<ContentVisualizer> {

  @override
  void initState() {
    widget.animation.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: SideMenuViewInherited.of(context).isWithTopBarMode?
          BorderRadius.circular(          
            widget.borderRadius * widget.animation.value
          ):
          null
      ),
      child: Stack(
        children: [
          Column(
            children: [
              if(SideMenuViewInherited.of(context).isWithTopBarMode)
              ContentVisualizerTopBar(
                onMenuButton: widget.onMenuButton,
                topBarActionWidget: SideMenuViewInherited.of(context).topBarActionWidget,
              ),
              Expanded(
                child: SideMenuViewInherited.of(context).content,
              )
            ],
          ),
          if(SideMenuViewInherited.of(context).opened
          && (SideMenuViewInherited.of(context).isWithTopBarMode))
          GestureDetector(
            onTap: () {
              SideMenuViewInherited.of(context).close();
            },
            child: Container(color: Colors.black.withAlpha(1)),
          )
        ],
      ),
    );
  }
}

/// Widget che rappresenta la topbar rappresentata in alto nel [ContentVisualizer].
/// Permette accedere al menu, visualizzare il titolo di ogni pagina, corrispondente
/// al nome del pulsante chiamante e visualizza anche il [topBarActionWidget]
/// a destra della barra.

class ContentVisualizerTopBar extends StatefulWidget{
  static const double barHeight = 65;

  final VoidCallback onMenuButton;
  final Widget? topBarActionWidget;
  
  const ContentVisualizerTopBar({
    super.key,
    required this.onMenuButton,
    this.topBarActionWidget
  });

  @override
  State<ContentVisualizerTopBar> createState() => _ContentVisualizerTopBarState();
}

class _ContentVisualizerTopBarState extends State<ContentVisualizerTopBar> {

  void menuPressed()
  {
    widget.onMenuButton.call();
  }

  @override
  Widget build(BuildContext context) {
    String? title = SideMenuViewInherited.of(context).lastActive?.name;

    return Container(
      height: ContentVisualizerTopBar.barHeight,
      color: Theme.of(context).dialogBackgroundColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    menuPressed();
                  },
                  child: Icon(
                    SideMenuViewInherited.of(context).opened?
                    Icons.close:
                    Icons.menu 
                  ),
                ),
                Text(
                  title ?? "Vuoto",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Icon(Icons.menu, color: Colors.transparent,),
              ],
            ),
          ),
          if(widget.topBarActionWidget != null)
          Positioned(
            right: 0,
            child: widget.topBarActionWidget!
          )
        ],
      ),
    );
  }
}