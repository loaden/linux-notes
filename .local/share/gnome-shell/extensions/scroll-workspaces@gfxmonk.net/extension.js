import Clutter from 'gi://Clutter';
import Meta from 'gi://Meta';
import * as WorkspaceSwitcherPopup from 'resource:///org/gnome/shell/ui/workspaceSwitcherPopup.js';
import {Extension, gettext as _} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const BUFFER_SHOW_ALL_WORKSPACES = 0;
const BUFFER_IGNORE_LAST_WORKSPACE = 1;

export default class ScrollWorkspaces extends Extension {
	constructor(metadata) {
		super(metadata)
		console.log('scroll-workspace init()');
		this._lastScroll = Date.now();
		this._signals = []
	}
	
	_connect(target, name, fn) {
		let connection = target.connect(name, fn)
		this._signals.push([target, connection])
	}
	
	enable() {
		console.log('scroll-workspace enable()');

		// setup ignore-last-workspace pref
		const settings = this.getSettings()
		const panel = Main.panel;

		let update_ignore_last_workspace = () => {
			this._tailBuffer = settings.get_boolean('ignore-last-workspace') ? BUFFER_IGNORE_LAST_WORKSPACE : BUFFER_SHOW_ALL_WORKSPACES ;
		};
		this._connect(settings, 'changed::ignore-last-workspace', update_ignore_last_workspace)
		update_ignore_last_workspace(); // set initial value
		
		// setup scroll-delay pref
		let update_scroll_delay = () => {
			this._scroll_delay = settings.get_int('scroll-delay');
			// console.log('scroll-workspaces scroll delay: ' + this._scroll_delay);
		};
		this._connect(settings, 'changed::scroll-delay', update_scroll_delay)
		update_scroll_delay(); // set initial value

		// setup wrap pref
		let update_wrap = () => {
			this._wrap = settings.get_boolean('wrap');
			// console.log('scroll-workspaces wrap: ' + this._wrap);
		};
		this._connect(settings, 'changed::wrap', update_wrap)
		update_wrap(); // set initial value

		// setup indicator pref
		let update_indicator = () => {
			this._indicator = settings.get_boolean('indicator');
			// console.log('scroll-workspaces indicator enabled: ' + this._indicator);
		};
		this._connect(settings, 'changed::indicator', update_indicator)
		update_indicator(); // set initial value


		panel.reactive = true;
		this._connect(panel, 'scroll-event', this._onScrollEvent.bind(this));
	}

	disable() {
		console.log('scroll-workspace disable()');

		for (let pair of this._signals) {
			let target = pair[0]
			let connection = pair[1]
			target.disconnect(connection)
		}
		this._signals = []
	}

	_onScrollEvent(_actor, event) {
		let motion;
		let scroll_direction = event.get_scroll_direction();

		// If layout is horizontal, treat up/down as left/right
		if (global.workspaceManager.layout_rows === 1) {
			switch (scroll_direction) {
			case Clutter.ScrollDirection.UP:
				scroll_direction = Clutter.ScrollDirection.LEFT;
				break;
			case Clutter.ScrollDirection.DOWN:
				scroll_direction = Clutter.ScrollDirection.RIGHT;
				break;
			}
		}

		switch (scroll_direction) {
		case Clutter.ScrollDirection.UP:
			motion = Meta.MotionDirection.UP;
			break;
		case Clutter.ScrollDirection.DOWN:
			motion = Meta.MotionDirection.DOWN;
			break;
		case Clutter.ScrollDirection.LEFT:
			motion = Meta.MotionDirection.LEFT;
			break;
		case Clutter.ScrollDirection.RIGHT:
			motion = Meta.MotionDirection.RIGHT;
			break;
		default:
			return Clutter.EVENT_PROPAGATE;
		}
		let activeWs = global.workspaceManager.get_active_workspace();
		let ws = activeWs.get_neighbor(motion);
		if(!ws) return Clutter.EVENT_STOP;

		let currentTime = Date.now();
		
		// console.log("scroll time diff = " + (currentTime - this._lastScroll));
		if (currentTime < this._lastScroll + this._scroll_delay) {
			if (currentTime < this._lastScroll) {
				// Clock went backwards. Reset & accept event
				this._lastScroll = 0;
			} else {
				// within wait period - consume this event (but do nothing)
				// to prevent accidental rapid scrolling
				return Clutter.EVENT_STOP;
			}
		}

		let tailBuffer = Main.overview.visible ? BUFFER_SHOW_ALL_WORKSPACES : this._tailBuffer;
		var wsIndex = ws.index();
		var numWorkspaces = global.workspaceManager.n_workspaces - tailBuffer;

		if (this._wrap && (ws == activeWs || wsIndex >= numWorkspaces)) {
			if (wsIndex === 0) {
				ws = global.workspaceManager.get_workspace_by_index(numWorkspaces-1)
			} else {
				ws = global.workspaceManager.get_workspace_by_index(0)
			}
		}

		if (ws.index() >= global.workspaceManager.n_workspaces - tailBuffer) {
			return Clutter.EVENT_STOP
		}

		if (this._indicator) {
			// The following code is taken from and thus compatible with the dash-to-dock extension by micheleg
			// which can be found at https://github.com/micheleg/dash-to-dock/blob/master/dockedDash.js.
			if (Main.wm._workspaceSwitcherPopup == null)
				Main.wm._workspaceSwitcherPopup = new WorkspaceSwitcherPopup.WorkspaceSwitcherPopup();
				// Set the actor non reactive, so that it doesn't prevent the
				// clicks events from reaching the dash actor. I can't see a reason
				// why it should be reactive.
				Main.wm._workspaceSwitcherPopup.reactive = false;
				Main.wm._workspaceSwitcherPopup.connect('destroy', () => {
					Main.wm._workspaceSwitcherPopup = null;
				});

			// Do not show wokspaceSwithcer in overview
			if(!Main.overview.visible)
				Main.wm._workspaceSwitcherPopup.display(ws.index());
			// End of code taken from dash-to-dock.
		}

		Main.wm.actionMoveWorkspace(ws);
		this._lastScroll = currentTime;
		return Clutter.EVENT_STOP;
	}
}
