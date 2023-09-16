/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx = 1; /* border pixel of windows */
static const unsigned int snap = 32;    /* snap pixel */
static const unsigned int systraypinning =
    0; /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor
          X */
static const unsigned int systrayonleft =
    0; /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2; /* systray spacing */
static const int systraypinningfailfirst =
    1; /* 1: if pinning fails, display systray on the first monitor, False:
          display systray on the last monitor*/
static const int showsystray = 0;               /* 0 means no systray */
static const unsigned int systrayiconsize = 16; /* systray icon size in px */

static const int swallowfloating =
    0; /* 1 means swallow floating windows by default */

static const unsigned int gappx = 8; /* gaps between windows */
static const int vertpad = 0;        /* vertical padding of bar */
static const int sidepad = gappx;    /* horizontal padding of bar */

static const int barpad = 4; /* horizontal padding of bar */
static const int user_bh =
    6; /* 2 is the default spacing around the bar's font */

static const int showbar = 1; /* 0 means no bar */
static const int topbar = 1;  /* 0 means bottom bar */
static const char *fonts[] = {"JetBrainsMono Nerd Font:style:light:size=10.5"};
static const char dmenufont[] =
    "JetBrainsMono Nerd Font:style:medium:size=12.5";

static const unsigned int ulinepad =
    5; /* horizontal padding between the underline and tag */
static const unsigned int ulinestroke =
    2; /* thickness / height of the underline */
static const unsigned int ulinevoffset =
    1; /* how far above the bottom of the bar the line should appear */
static const int ulineall =
    0; /* 1 to show underline on all tags, 0 for just the active ones */

static const char color_bg[] = "#11111a";
static const char color_fg[] = "#b4befe";
static const char color_blue[] = "#89B4FA";
static const char color_gray[] = "#45475a";

static const char *colors[][3] = {
    /*               fg         bg         border   */
    [SchemeNorm] = {color_gray, color_bg, color_bg},
    [SchemeSel] = {color_gray, color_bg, color_gray},
    [SchemeTitle] = {color_fg, color_bg, color_bg},
};

static const char *const autostart[] = {
    "dwmblocks",
    NULL,
    "dunst",
    NULL,
    "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1",
    NULL,
    NULL /* terminate */
};

/* tagging */
static const char *tags[] = {"1", "2", "3", "4", "5", "6", "7", "8", "9"};

static const char *tagsel[][2] = {
    {"#89B4FA", color_bg}, {"#f38ba8", color_bg}, {"#a6e3a1", color_bg},
    {"#f9e2af", color_bg}, {"#fab387", color_bg}, {"#cba6f7", color_bg},
    {"#b4befe", color_bg}, {"#89B4FA", color_bg}, {"#89B4FA", color_bg},
};

static const Rule rules[] = {
    /* xprop(1):
     *	WM_CLASS(STRING) = instance, class
     *	WM_NAME(STRING) = title
     */
    /* class                                instance  title       tags mask
       isfloating  isterminal  noswallow  monitor */
    {"Gimp", NULL, NULL, 0, 1, 0, 0, -1},
    {"Lutris", NULL, NULL, 0, 1, 0, 0, -1},
    {"steam", NULL, NULL, 1 << 4, 0, 0, 0, -1},
    {"gnome-calculator", NULL, NULL, 0, 1, 0, 0, -1},
    {"gnome-calendar", NULL, NULL, 0, 1, 0, 0, -1},
    {"Firefox", NULL, NULL, 0, 0, 0, 0, -1},
    {"qBittorrent", NULL, NULL, 1 << 4, 0, 0, 0, 1},
    {"KeePassXC", NULL, NULL, 1 << 5, 0, 0, 0, 1},
    {"Spotify", NULL, NULL, 1 << 2, 0, 0, 0, 1},
    {"kitty", NULL, NULL, 0, 0, 1, 0, -1},
    {"polkit-gnome-authentication-agent-1", NULL, NULL, 0, 1, 0, 0, -1},
    {"mpv", NULL, NULL, 0, 0, 0, 0, 0},

    {NULL, NULL, "Event Tester", 0, 0, 0, 1, -1}, /* xev */
};

/* layout(s) */
static const float mfact = 0.66; /* factor of master area size [0.05..0.95] */
static const int nmaster = 1;    /* number of clients in master area */
static const int resizehints =
    0; /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen =
    1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
    /* symbol     arrange function */
    {"󰙀", tilewide},
    {"><>", NULL}, /* no layout function means floating behavior */
    {"", monocle},
    {"[]=", tile}, /* first entry is default */
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY, TAG)                                                      \
  {MODKEY, KEY, view, {.ui = 1 << TAG}},                                       \
      {MODKEY | ControlMask, KEY, toggleview, {.ui = 1 << TAG}},               \
      {MODKEY | ShiftMask, KEY, tag, {.ui = 1 << TAG}},                        \
      {MODKEY | ControlMask | ShiftMask, KEY, toggletag, {.ui = 1 << TAG}},

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd)                                                             \
  {                                                                            \
    .v = (const char *[]) { "/bin/sh", "-c", cmd, NULL }                       \
  }

#define STATUSBAR "dwmblocks"
#include <X11/XF86keysym.h>

/* If you use pipewire add somewhere in your constants definition section. Use
   "wpctl status" to find out the real sink ID, 0 is a placeholder here. */
static const char *upvol[] = {"dwm-volume-change", "5%+", NULL};
static const char *downvol[] = {"dwm-volume-change", "5%-", NULL};
static const char *mutevol[] = {"dwm-volume-change", "toggle", NULL};

/* commands */
static char dmenumon[2] =
    "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = {
    "dmenu_run", "-m",  dmenumon,   "-fn", dmenufont,  "-nb", color_bg, "-nf",
    color_fg,    "-sb", color_gray, "-sf", color_blue, NULL};
static const char *termcmd[] = {"kitty", NULL};
static const char *browsercmd[] = {"firefox", NULL};
static const char *privatebrowsercmd[] = {"firefox", "--private-window", NULL};
static const char *altbrowsercmd[] = {"brave-browser", NULL};
static const char *roficmd[] = {"rofi", "-show", "drun", NULL};
static const char *gpickcmd[] = {"dwm-gpick", NULL};
static const char *filesguicmd[] = {"nemo", NULL};
static const char *filestuicmd[] = {"kitty", "-e", "ranger", NULL};
static const char *screengrab[] = {"flameshot", "gui", NULL};
static const char *screenshot[] = {"dwm-screenshot"};

static const Key keys[] = {
    /* modifier                     key        function        argument */
    {MODKEY, XK_r, spawn, {.v = dmenucmd}},
    {MODKEY, XK_space, spawn, {.v = roficmd}},
    {MODKEY, XK_Return, spawn, {.v = termcmd}},
    {MODKEY, XK_f, spawn, {.v = browsercmd}},
    {MODKEY, XK_b, spawn, {.v = altbrowsercmd}},
    {MODKEY | ShiftMask, XK_b, spawn, {.v = privatebrowsercmd}},
    {MODKEY, XK_c, spawn, {.v = gpickcmd}},
    {MODKEY, XK_e, spawn, {.v = filestuicmd}},
    {MODKEY | ShiftMask, XK_e, spawn, {.v = filesguicmd}},
    {MODKEY, XK_p, spawn, {.v = screengrab}},
    {MODKEY | ShiftMask, XK_p, spawn, {.v = screenshot}},
    {MODKEY, XK_w, togglebar, {0}},
    {MODKEY, XK_j, focusstack, {.i = +1}},
    {MODKEY, XK_k, focusstack, {.i = -1}},
    {MODKEY, XK_i, incnmaster, {.i = +1}},
    {MODKEY, XK_d, incnmaster, {.i = -1}},
    {MODKEY, XK_h, setmfact, {.f = -0.05}},
    {MODKEY, XK_l, setmfact, {.f = +0.05}},
    {MODKEY | ShiftMask, XK_j, zoom, {0}},
    {MODKEY, XK_Tab, view, {0}},
    {MODKEY | ShiftMask, XK_q, killclient, {0}},
    {MODKEY, XK_t, setlayout, {.v = &layouts[0]}},
    {MODKEY, XK_m, setlayout, {.v = &layouts[2]}},
    {MODKEY | ShiftMask, XK_space, togglefloating, {0}},
    {MODKEY | ShiftMask, XK_f, togglefullscr, {0}},
    {MODKEY, XK_0, view, {.ui = ~0}},
    {MODKEY | ShiftMask, XK_0, tag, {.ui = ~0}},
    {MODKEY, XK_comma, focusmon, {.i = -1}},
    {MODKEY, XK_period, focusmon, {.i = +1}},
    {MODKEY | ShiftMask, XK_comma, tagmon, {.i = -1}},
    {MODKEY | ShiftMask, XK_period, tagmon, {.i = +1}},
    TAGKEYS(XK_1, 0) TAGKEYS(XK_2, 1) TAGKEYS(XK_3, 2) TAGKEYS(XK_4, 3)
        TAGKEYS(XK_5, 4) TAGKEYS(XK_6, 5) TAGKEYS(XK_7, 6) TAGKEYS(XK_8, 7)
            TAGKEYS(XK_9, 8){MODKEY | ControlMask | ShiftMask, XK_r, quit, {0}},

    {0, XF86XK_AudioLowerVolume, spawn, {.v = downvol}},
    {0, XF86XK_AudioMute, spawn, {.v = mutevol}},
    {0, XF86XK_AudioRaiseVolume, spawn, {.v = upvol}},
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle,
 * ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
    /* click                event mask      button          function argument */
    // { ClkLtSymbol,          0,              Button1,        setlayout, {0} },
    // { ClkLtSymbol,          0,              Button3,        setlayout, {.v =
    // &layouts[2]} },

    /* placemouse options, choose which feels more natural:
     *    0 - tiled position is relative to mouse cursor
     *    1 - tiled postiion is relative to window center
     *    2 - mouse pointer warps to window center
     *
     * The moveorplace uses movemouse or placemouse depending on the floating
     * state of the selected client. Set up individual keybindings for the two
     * if you want to control these separately (i.e. to retain the feature to
     * move a tiled window into a floating position).
     */
    // { ClkClientWin,         MODKEY|ShiftMask, Button1,      dragmfact, {0} },
    {ClkClientWin, MODKEY, Button1, moveorplace, {.i = 1}},
    {ClkClientWin, MODKEY, Button2, togglefloating, {0}},
    {ClkClientWin, MODKEY, Button3, resizefloating, {0}},
    {ClkTagBar, 0, Button1, view, {0}},
    {ClkTagBar, 0, Button3, toggleview, {0}},
    {ClkTagBar, MODKEY, Button1, tag, {0}},
    {ClkTagBar, MODKEY, Button3, toggletag, {0}},
    {ClkStatusText, 0, Button1, sigstatusbar, {.i = 1}},
    {ClkStatusText, 0, Button2, sigstatusbar, {.i = 2}},
    {ClkStatusText, 0, Button3, sigstatusbar, {.i = 3}},
};
