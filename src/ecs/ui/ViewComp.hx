package ecs.ui;

import h2d.Object;
import ecs.tools.WorldEditor.EntityField;

@:uiComp("view")
// Naming scheme of component classes can be customized with domkit.Macros.registerComponentsPath();
class ViewComp extends h2d.Flow implements h2d.domkit.Object {

	static var SRC =
	<view class="mybox" id="myview" debug={true} overflow="hidden" content-halign={align}>
        for(i in entityFields) {
            <text public id="fields[]" text={i.name}/>
            <text public id="fields[]" text={Std.string(i.data)}/>
            <flow></flow>
        }
	</view>;

	public function new(align:h2d.Flow.FlowAlign, entityFields:Array<EntityField>, ?parent:Object) {
		super(parent);
        this.overflow = Scroll;
		initComponent();
	}
}

