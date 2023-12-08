import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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

  late AnimationController _controller;
  late Animation<double> animation;

  GlobalKey<_ContentVisualizerState> contentKey = GlobalKey(); 

  void changeState(SideMenuButton? newButton)
  {
    setState(() {
      lastActive = newButton;
    });
  }

  @override
  void initState() {
    super.initState();

    // Multiple buttons name check
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
          "No content found. "
          "At least one button should have content to visualize."
        );
      }
      
      return true;
    });

    changeState(buttonWithContent);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
      setState(() {});
    });

    animation = Tween<double>(begin: 0, end: 1).animate(_controller);    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    menuLeftPositionOpened = MediaQuery.of(context).size.width / 3;

    return WillPopScope(
      onWillPop: () async {
        bool isOpened = animation.isCompleted;
        if(isOpened)
        {
          contentKey.currentState?.topBarState.currentState?.menuPressed();
        }
        return !isOpened;
      },
      child: Scaffold(
        body: Container(
          color: Theme.of(context).primaryColorDark,
          child: SafeArea(
            child: _SideMenuViewInherited(
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
                          key: contentKey,
                          animation: animation,
                          topBarActionWidget: widget.topBarActionWidget,
                          borderRadius: widget.contentBorderRadius,
                          onMenuButton: (bool state){
                            if(state)
                            {
                              _controller.forward();
                            }
                            else{
                              _controller.reverse();
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ),
        ),
      ),
    );
  }  
}

class _SideMenuViewInherited extends InheritedWidget{   

  final SideMenuButton? lastActive;
  final Widget content;


  const _SideMenuViewInherited({
    this.lastActive,
    required this.content,
    required super.child
  });
  

  static _SideMenuViewInherited? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SideMenuViewInherited>();
  }

  static _SideMenuViewInherited of(BuildContext context) {
    final _SideMenuViewInherited? result = _maybeOf(context);
    assert(result != null, 'No _SideMenuViewInherited found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

}

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
            title,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600
            ),
          ),
        ),        
        ...buttons.map((e) => _SideMenuButton(
            button: e,
          )
        ),
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

class SideMenuButton{
  final String name;
  final Widget icon;
  final Widget? content;
  final VoidCallback? onPressed;

  const SideMenuButton({
    required this.name,
    required this.icon,
    this.content,
    this.onPressed
  });
}


class _SideMenuButton extends StatefulWidget{
  final SideMenuButton button;
  
  const _SideMenuButton({
    required this.button
  });  

  @override
  State<_SideMenuButton> createState() => _SideMenuButtonState();
}

class _SideMenuButtonState extends State<_SideMenuButton> {

  bool _isActive = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SideMenuButton? lastActive = _SideMenuViewInherited.of(context).lastActive;


    if(lastActive != null)
    {
      _isActive = lastActive.name  == widget.button.name;
    }
      
    return Material(
      color: !_isActive? Colors.transparent : Theme.of(context).primaryColorLight,
      child: InkWell(
        onTap: (){
          if(widget.button.content!=null)
          {
            context
            .findAncestorStateOfType<_SideMenuViewState>()
            !.changeState(widget.button);
          }         

          widget.button.onPressed?.call();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                widget.button.icon,
                const Gap(10),
                Text(
                  widget.button.name,
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


class ContentVisualizer extends StatefulWidget{

  final Animation<double> animation;
  final void Function(bool state) onMenuButton;
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
  GlobalKey<_ContentVisualizerTopBarState> topBarState = GlobalKey();

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
                key: topBarState,
                onMenuButton: (bool state){
                  widget.onMenuButton(state);
                },
                topBarActionWidget: widget.topBarActionWidget,
              ),
              Expanded(
                child: _SideMenuViewInherited.of(context).content,
              )
            ],
          ),
          if(topBarState.currentState?.menuOpened ?? false)
          GestureDetector(
            onTap: () {
              topBarState.currentState?.menuPressed();
            },
            child: Container(color: Colors.black.withAlpha(1)),
          )
        ],
      ),
    );
  }
}

class ContentVisualizerTopBar extends StatefulWidget{
  static const double barHeight = 65;

  final void Function(bool state) onMenuButton;
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

  bool menuOpened = false;

  void menuPressed()
  {
    menuOpened = !menuOpened;
    widget.onMenuButton.call(menuOpened);
  }

  @override
  Widget build(BuildContext context) {
    String? title = _SideMenuViewInherited.of(context).lastActive?.name;

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
                  style: Theme.of(context).textTheme.headlineMedium,
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