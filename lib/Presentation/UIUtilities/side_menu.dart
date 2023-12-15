import 'dart:math';

import 'package:flutter/material.dart';
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
  static const double _scaleDownPercentage = 0.05;

  final int initialContentIndex;
  final List<SideMenuGroup> groups;
  final bool rotate3D;
  final Widget? topBarActionWidget;
  final double contentBorderRadius;

  const SideMenuView({
    super.key,
    required this.groups,
    this.initialContentIndex = 0,
    this.rotate3D = true,
    this.topBarActionWidget,
    this.contentBorderRadius = 10
  });

  @override
  State<SideMenuView> createState() => _SideMenuViewState();
}

class _SideMenuViewState extends State<SideMenuView> 
  with SingleTickerProviderStateMixin{

  double menuLeftPositionOpened = 400;

  SideMenuButton? lastActive;

  AnimationController? _controller;
  late Animation<double> animation;

  GlobalKey<_ContentVisualizerState> contentKey = GlobalKey(); 

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

  @override
  void initState() {
    super.initState();   

    checkAndFetchContent();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
      setState(() {});
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
    if(!currentPageStillExists())
    {
      checkAndFetchContent();
    }

    menuLeftPositionOpened = MediaQuery.of(context).size.width / 3;

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
            onCloseRequest: close,
            onOpenRequest: open,
            onChangeStateRequest: (state) => changeState(state),
            lastActive: lastActive,
            content: lastActive?.content ?? Container(),
            child: Stack(
              children: [
                SideMenu(groups: widget.groups),
                Positioned(
                  left: menuLeftPositionOpened * animation.value,
                  top: 0,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height-
                          MediaQuery.of(context).padding.top,
                  child: Transform.scale(
                    alignment: Alignment.center,
                    scale: 1 - SideMenuView._scaleDownPercentage * animation.value,
                    child: Transform(
                      transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0005)
                      ..rotateY(widget.rotate3D? pi/5 * animation.value : 0),
                      alignment: Alignment.center,
                      child: ContentVisualizer(
                        animation: animation,
                        topBarActionWidget: widget.topBarActionWidget,
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
  final Widget content;
  final bool opened;

  final VoidCallback onCloseRequest;
  final VoidCallback onOpenRequest;
  final void Function(SideMenuButton? button) _onChangeStateRequest;


  const SideMenuViewInherited({
    super.key, 
    this.lastActive,
    required this.content,
    required this.opened,
    required this.onCloseRequest,
    required this.onOpenRequest,
    required void Function(SideMenuButton? button) onChangeStateRequest,
    required super.child,
  }): _onChangeStateRequest = onChangeStateRequest;
  

  static SideMenuViewInherited? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SideMenuViewInherited>();
  }

  static SideMenuViewInherited of(BuildContext context) {
    final SideMenuViewInherited? result = _maybeOf(context);
    assert(result != null, 'No _SideMenuViewInherited found in context');
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: groups,
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
      color: !_isActive? Colors.transparent : Theme.of(context).primaryColorDark,
      child: InkWell(
        onTap: (){
          if(widget.content!=null)
          {            
            SideMenuViewInherited.of(context)._changePage(widget);
          }         

          widget.onPressed?.call();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                widget.icon,
                const Gap(10),
                Text(
                  widget.name,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary
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
  final Widget? topBarActionWidget;
  final double borderRadius;

  const ContentVisualizer({
    super.key,
    required this.animation,
    required this.onMenuButton,
    required this.borderRadius,
    this.topBarActionWidget
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
        borderRadius: BorderRadius.circular(
          widget.borderRadius * widget.animation.value
        )
      ),
      child: Stack(
        children: [
          Column(
            children: [
              ContentVisualizerTopBar(
                onMenuButton: widget.onMenuButton,
                topBarActionWidget: widget.topBarActionWidget,
              ),
              Expanded(
                child: SideMenuViewInherited.of(context).content,
              )
            ],
          ),
          if(SideMenuViewInherited.of(context).opened)
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
                  child: const Icon(Icons.menu),
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