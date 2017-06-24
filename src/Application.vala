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

public class Wallpaperize.Application : Granite.Application {
    public const string PROGRAM_ID = "com.github.philip-scott.wallpaperize";
    public const string PROGRAM_NAME = "Wallpaperize";

    construct {
        flags |= ApplicationFlags.HANDLES_OPEN;

        application_id = PROGRAM_ID;
        program_name = PROGRAM_NAME;
        app_years = "2016-2017";
        exec_name = PROGRAM_ID;
        app_launcher = PROGRAM_ID;

        build_version = "1.0";
        app_icon = PROGRAM_ID;
        main_url = "https://github.com/Philip-Scott/%s/".printf (PROGRAM_NAME);
        bug_url = "https://github.com/Philip-Scott/%s/issues".printf (PROGRAM_NAME);
        help_url = "https://github.com/Philip-Scott/%s/issues".printf (PROGRAM_NAME);
        translate_url = "https://github.com/Philip-Scott/%s/tree/master/po".printf (PROGRAM_NAME);
        about_authors = {"Felipe Escoto <felescoto95@hotmail.com>", null};
        about_translators = _("translator-credits");

        about_license_type = Gtk.License.GPL_3_0;
    }

    public override void open (File[] files, string hint) {
        Wallpaperize.Wallpaperiser.get_monitor_geometry ();
        foreach (var file in files) {
            Wallpaperize.Wallpaperiser.from_file (file); 
        }
    }

    public override void activate () {
        var window = new Wallpaperize.Window (this);
        this.add_window (window);
        window.show ();
    }

    public static int main (string[] args) {
        /* Initiliaze gettext support */
        Intl.setlocale (LocaleCategory.MESSAGES, Intl.get_language_names ()[0]);
        Intl.setlocale (LocaleCategory.NUMERIC, "en_US");
        //Intl.textdomain (Config.GETTEXT_PACKAGE);

        Environment.set_application_name (PROGRAM_NAME);
        Environment.set_prgname (PROGRAM_NAME);

        var application = new Wallpaperize.Application ();

        return application.run (args);
    }
}
