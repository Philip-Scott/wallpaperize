project('com.github.philip-scott.wallpaperize', 'vala', 'c', version: '0.2.0')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('granite')
]

subdir('src')

executable(
    meson.project_name(),   
    sources,
    dependencies: dependencies,
    install : true
)

subdir('data')

meson.add_install_script('meson/post_install.py')
