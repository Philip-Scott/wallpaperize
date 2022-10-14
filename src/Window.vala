/*
* Copyright (c) 2017 Felipe Escoto (https://github.com/Philip-Scott)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
* Authored by: Felipe Escoto <felescoto95@hotmail.com>
*/

public class Wallpaperize.Window : Gtk.Window {
  const int MIN_WIDTH = 450;
  const int MIN_HEIGHT = 600;
  const int IMAGE_HEIGHT = 200;

  const Gtk.TargetEntry[] DRAG_TARGETS = {{ "text/uri-list", 0, 0 }};

  const string STYLESHEET = """
    .titlebar {
        background-color: @bg_color;
        background-image: none;
        border: none;
        box-shadow: none;
        padding: 16px;
    }
  """;

  public Gtk.Image image;
  public Gtk.Button cancel_button;
  public Gtk.Button run_button;
  public Gtk.Label drag_label;

  public Gtk.Entry width;
  public Gtk.Entry height;

  private File? _file = null;
  public File? file {
      get {
          return _file;
      }

      set {
          _file = value;
          if (value == null) {
            return;
          }

          var surface = Wallpaperize.Wallpaperiser.make_surface (value.get_path ());

          if (surface != null) {
            var pixbuf = surface.load_to_pixbuf ();
            pixbuf = pixbuf.scale_simple (image.get_allocated_width (), image.get_allocated_height (), Gdk.InterpType.BILINEAR);

            image.set_from_pixbuf (pixbuf);
            run_button.label = _("Wallpaperize!");
            drag_label.visible = false;
            drag_label.no_show_all = true;

            validate ();
          }
      }
  }

  public Window (Gtk.Application app) {
      Object (application: app);
  }

  construct {
    Granite.Widgets.Utils.set_theming_for_screen (this.get_screen (), STYLESHEET, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    get_style_context ().add_class ("rounded");
    set_size_request(MIN_WIDTH, MIN_HEIGHT);

    Gtk.drag_dest_set (this, Gtk.DestDefaults.MOTION | Gtk.DestDefaults.DROP, DRAG_TARGETS, Gdk.DragAction.COPY);
    drag_data_received.connect (on_drag_data_received);

    resizable = false;
    deletable = false;
    set_keep_above (true);

    var grid = new Gtk.Grid ();
    grid.orientation = Gtk.Orientation.VERTICAL;
    grid.column_spacing = 12;
    grid.row_spacing = 12;
    grid.expand = true;
    grid.margin = 6;

    image = new Gtk.Image ();
    image.get_style_context ().add_class ("card");
    image.hexpand = true;
    image.height_request = 200;
    image.margin = 6;

    drag_label = new Gtk.Label (_("Drop Image Here"));
    drag_label.justify = Gtk.Justification.CENTER;

    var drag_label_style_context = drag_label.get_style_context ();
    drag_label_style_context.add_class ("h2");
    drag_label_style_context.add_class (Gtk.STYLE_CLASS_DIM_LABEL);

    var overlay = new Gtk.Overlay ();
    overlay.add (image);
    overlay.add_overlay (drag_label);

    width = new Gtk.Entry ();
    height = new Gtk.Entry ();

    width.input_purpose = Gtk.InputPurpose.DIGITS;
    height.input_purpose = Gtk.InputPurpose.DIGITS;

    width.set_tooltip_text (_("Width"));
    height.set_tooltip_text (_("Height"));

    width.changed.connect (() => {
        Wallpaperize.Wallpaperiser.W = int.parse (width.text);
        validate ();
    });

    height.changed.connect (() => {
        Wallpaperize.Wallpaperiser.H = int.parse (height.text);
        validate ();
    });

    var reset_button = new Gtk.Button.from_icon_name ("video-display-symbolic");
    reset_button.clicked.connect (get_screen_size);
    reset_button.set_tooltip_text (_("Get resolution"));

    var resolution_box = new Gtk.Grid ();
    resolution_box.column_spacing = 6;
    resolution_box.margin = 6;
    resolution_box.add (width);
    resolution_box.add (new Gtk.Label ("\u00D7"));
    resolution_box.add (height);
    resolution_box.add (reset_button);

    cancel_button = new Gtk.Button.with_label (_("Cancel"));
    run_button = new Gtk.Button.with_label (_("Wallpaperize!"));
    run_button.get_style_context ().add_class ("suggested-action");

    var actions_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
    actions_box.pack_start (cancel_button);
    actions_box.pack_end (run_button);
    actions_box.expand = true;
    actions_box.halign = Gtk.Align.END;
    actions_box.valign = Gtk.Align.END;
    actions_box.margin = 6;

    cancel_button.clicked.connect (() => {
        this.close ();
    });

    run_button.sensitive = false;
    run_button.clicked.connect (() => {
    run_button.sensitive = false;
    Wallpaperize.Wallpaperiser.from_file (file);
        run_button.label = _("Done");
    });

    grid.attach (overlay, 0, 0, 1, 1);
    grid.attach (resolution_box, 0, 1, 1, 1);
    grid.attach (actions_box, 0, 2, 1, 1);
    this.add (grid);

    show_all ();
    get_screen_size ();
  }

  private void validate () {
      int w = Wallpaperiser.W;
      int h = Wallpaperiser.H;
      run_button.sensitive = w > 0 && h > 0 && w < 15000 && h < 15000 && file != null;
  }

  private void get_screen_size () {
      Wallpaperize.Wallpaperiser.get_monitor_geometry ();

      width.text = Wallpaperize.Wallpaperiser.W.to_string ();
      height.text = Wallpaperize.Wallpaperiser.H.to_string ();
  }

  private void on_drag_data_received (Gdk.DragContext drag_context, int x, int y, Gtk.SelectionData data, uint info, uint time) {
    stderr.printf (data.get_uris ()[0]);
    Gtk.drag_finish (drag_context, true, false, time);

    file = File.new_for_uri (data.get_uris ()[0]);
  }
}
