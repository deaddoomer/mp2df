(* Copyright (C)  SovietPony
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License ONLY.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)

{$MODE OBJFPC}
{$MODESWITCH ANSISTRINGS+}
{$MODESWITCH AUTODEREF+}
{$MODESWITCH CLASSICPROCVARS+}
{$MODESWITCH DEFAULTPARAMETERS+}
{$MODESWITCH DUPLICATELOCALS-}
{$MODESWITCH EXCEPTIONS+}
{$MODESWITCH HINTDIRECTIVE+}
{$MODESWITCH NESTEDCOMMENTS+}
{$MODESWITCH NESTEDPROCVARS+}
{$MODESWITCH OBJPAS+}
{$MODESWITCH OUT+}
{$MODESWITCH PCHARTOSTRING+}
{$MODESWITCH POINTERTOPROCVAR+}
{$MODESWITCH REPEATFORWARD+}
{$MODESWITCH RESULT+}
{$MODESWITCH UNICODESTRINGS-}

{$ASSERTIONS ON}
{$COPERATORS ON}
{$EXTENDEDSYNTAX ON}

program mp2df;

  uses Classes, SysUtils, Math, SDL, SDL_image;

  const
    (* MP Tiles *)
    MP_WALL = 0;
    MP_STEP = 1;
    MP_BACK = 2;
    MP_FORE = 3;
    MP_WATER = 4;
    MP_ACID1 = 5;
    MP_ACID2 = 6;
    MP_LIFTUP = 7;
    MP_LIFTDOWN = 8;
    MP_LIFTLEFT = 9;
    MP_LIFTRIGHT = 10;

    (* MP Items *)
    MP_MEDKIT_SMALL = 11;
    MP_MEDKIT_LARGE = 12;
    MP_ARMOR_GREEN = 13;
    MP_ARMOR_BLUE = 14;
    MP_SPHERE_BLUE = 15;
    MP_SPHERE_WHITE = 16;
    MP_INVUL = 17;
    MP_JETPACK = 18;
    MP_MEDKIT_BLACK = 19;
    MP_AMMO_BACKPACK = 20;
    MP_AMMO_BULLETS = 21;
    MP_AMMO_BULLETS_BOX = 22;
    MP_AMMO_SHELLS = 23;
    MP_AMMO_SHELLS_BOX = 24;
    MP_BOTTLE = 25;
    MP_HELMET = 26;
    MP_AMMO_ROCKET = 27;
    MP_AMMO_ROCKET_BOX = 28;
    MP_AMMO_CELL = 29;
    MP_AMMO_CELL_BIG = 30;
    MP_WEAPON_SHOTGUN1 = 31;
    MP_WEAPON_SHOTGUN2 = 32;
    MP_WEAPON_CHAINGUN = 33;
    MP_WEAPON_SAW = 34;
    MP_WEAPON_ROCKETLAUNCHER = 35;
    MP_WEAPON_PLASMA = 36;
    MP_WEAPON_BFG = 37;
    MP_WEAPON_SUPERPULEMET = 38;
    // areas and triggers here!
    MP_INVIS = 49;
    MP_SUIT = 50;

    (* MP Areas *)
    MP_DMPOINT = 39;
    MP_REDTEAMPOINT = 40;
    MP_BLUETEAMPOINT = 41;
    MP_REDFLAG = 42;
    MP_BLUEFLAG = 43;

    (* MP Trigger activation *)
    MP_COLLIDE = 44;
    MP_PRESS = 45;
    MP_SHOT = 46;
    MP_START = 47;
    MP_NOACT = 48;

    (* MP Trigger *)
    MP_CLOSEDOOR = 0;
    MP_OPENDOOR = 1;
    MP_DOOR = 2;
    MP_RANDOM = 3;
    MP_EXTENDER = 4;
    MP_SWITCH = 5;
    MP_DAMAGE = 6;
    MP_TELEPORT = 7;
    MP_EXIT = 8;

  const
    PANEL_NONE      = 0;
    PANEL_WALL      = 1;
    PANEL_BACK      = 2;
    PANEL_FORE      = 4;
    PANEL_WATER     = 8;
    PANEL_ACID1     = 16;
    PANEL_ACID2     = 32;
    PANEL_STEP      = 64;
    PANEL_LIFTUP    = 128;
    PANEL_LIFTDOWN  = 256;
    PANEL_OPENDOOR  = 512;
    PANEL_CLOSEDOOR = 1024;
    PANEL_BLOCKMON  = 2048;
    PANEL_LIFTLEFT  = 4096;
    PANEL_LIFTRIGHT = 8192;

    PANEL_FLAG_BLENDING      = 1;
    PANEL_FLAG_HIDE          = 2;
    PANEL_FLAG_WATERTEXTURES = 4;

    ITEM_NONE                  = 0;
    ITEM_MEDKIT_SMALL          = 1;
    ITEM_MEDKIT_LARGE          = 2;
    ITEM_MEDKIT_BLACK          = 3;
    ITEM_ARMOR_GREEN           = 4;
    ITEM_ARMOR_BLUE            = 5;
    ITEM_SPHERE_BLUE           = 6;
    ITEM_SPHERE_WHITE          = 7;
    ITEM_SUIT                  = 8;
    ITEM_OXYGEN                = 9;
    ITEM_INVUL                 = 10;
    ITEM_WEAPON_SAW            = 11;
    ITEM_WEAPON_SHOTGUN1       = 12;
    ITEM_WEAPON_SHOTGUN2       = 13;
    ITEM_WEAPON_CHAINGUN       = 14;
    ITEM_WEAPON_ROCKETLAUNCHER = 15;
    ITEM_WEAPON_PLASMA         = 16;
    ITEM_WEAPON_BFG            = 17;
    ITEM_WEAPON_SUPERPULEMET   = 18;
    ITEM_AMMO_BULLETS          = 19;
    ITEM_AMMO_BULLETS_BOX      = 20;
    ITEM_AMMO_SHELLS           = 21;
    ITEM_AMMO_SHELLS_BOX       = 22;
    ITEM_AMMO_ROCKET           = 23;
    ITEM_AMMO_ROCKET_BOX       = 24;
    ITEM_AMMO_CELL             = 25;
    ITEM_AMMO_CELL_BIG         = 26;
    ITEM_AMMO_BACKPACK         = 27;
    ITEM_KEY_RED               = 28;
    ITEM_KEY_GREEN             = 29;
    ITEM_KEY_BLUE              = 30;
    ITEM_WEAPON_KASTET         = 31;
    ITEM_WEAPON_PISTOL         = 32;
    ITEM_BOTTLE                = 33;
    ITEM_HELMET                = 34;
    ITEM_JETPACK               = 35;
    ITEM_INVIS                 = 36;
    ITEM_WEAPON_FLAMETHROWER   = 37;
    ITEM_AMMO_FUELCAN          = 38;

    ITEM_OPTION_ONLYDM = 1;
    ITEM_OPTION_FALL   = 2;

    AREA_NONE          = 0;
    AREA_PLAYERPOINT1  = 1;
    AREA_PLAYERPOINT2  = 2;
    AREA_DMPOINT       = 3;
    AREA_REDFLAG       = 4;
    AREA_BLUEFLAG      = 5;
    AREA_DOMFLAG       = 6;
    AREA_REDTEAMPOINT  = 7;
    AREA_BLUETEAMPOINT = 8;

    TRIGGER_NONE            = 0;
    TRIGGER_EXIT            = 1;
    TRIGGER_TELEPORT        = 2;
    TRIGGER_OPENDOOR        = 3;
    TRIGGER_CLOSEDOOR       = 4;
    TRIGGER_DOOR            = 5;
    TRIGGER_DOOR5           = 6;
    TRIGGER_CLOSETRAP       = 7;
    TRIGGER_TRAP            = 8;
    TRIGGER_PRESS           = 9;
    TRIGGER_SECRET          = 10;
    TRIGGER_LIFTUP          = 11;
    TRIGGER_LIFTDOWN        = 12;
    TRIGGER_LIFT            = 13;
    TRIGGER_TEXTURE         = 14;
    TRIGGER_ON              = 15;
    TRIGGER_OFF             = 16;
    TRIGGER_ONOFF           = 17;
    TRIGGER_SOUND           = 18;
    TRIGGER_SPAWNMONSTER    = 19;
    TRIGGER_SPAWNITEM       = 20;
    TRIGGER_MUSIC           = 21;
    TRIGGER_PUSH            = 22;
    TRIGGER_SCORE           = 23;
    TRIGGER_MESSAGE         = 24;
    TRIGGER_DAMAGE          = 25;
    TRIGGER_HEALTH          = 26;
    TRIGGER_SHOT            = 27;
    TRIGGER_EFFECT          = 28;
    TRIGGER_MAX             = 28;

    TRIGGER_SHOT_PISTOL  = 0;
    TRIGGER_SHOT_BULLET  = 1;
    TRIGGER_SHOT_SHOTGUN = 2;
    TRIGGER_SHOT_SSG     = 3;
    TRIGGER_SHOT_IMP     = 4;
    TRIGGER_SHOT_PLASMA  = 5;
    TRIGGER_SHOT_SPIDER  = 6;
    TRIGGER_SHOT_CACO    = 7;
    TRIGGER_SHOT_BARON   = 8;
    TRIGGER_SHOT_MANCUB  = 9;
    TRIGGER_SHOT_REV     = 10;
    TRIGGER_SHOT_ROCKET  = 11;
    TRIGGER_SHOT_BFG     = 12;
    TRIGGER_SHOT_EXPL    = 13;
    TRIGGER_SHOT_BFGEXPL = 14;
    TRIGGER_SHOT_FLAME   = 15;
    TRIGGER_SHOT_MAX     = 15;

    TRIGGER_SHOT_TARGET_NONE   = 0;
    TRIGGER_SHOT_TARGET_MON    = 1;
    TRIGGER_SHOT_TARGET_PLR    = 2;
    TRIGGER_SHOT_TARGET_RED    = 3;
    TRIGGER_SHOT_TARGET_BLUE   = 4;
    TRIGGER_SHOT_TARGET_MONPLR = 5;
    TRIGGER_SHOT_TARGET_PLRMON = 6;

    TRIGGER_SHOT_AIM_DEFAULT   = 0;
    TRIGGER_SHOT_AIM_ALLMAP    = 1;
    TRIGGER_SHOT_AIM_TRACE     = 2;
    TRIGGER_SHOT_AIM_TRACEALL  = 3;

    TRIGGER_EFFECT_PARTICLE  = 0;
    TRIGGER_EFFECT_ANIMATION = 1;

    TRIGGER_EFFECT_SLIQUID = 0;
    TRIGGER_EFFECT_LLIQUID = 1;
    TRIGGER_EFFECT_DLIQUID = 2;
    TRIGGER_EFFECT_BLOOD   = 3;
    TRIGGER_EFFECT_SPARK   = 4;
    TRIGGER_EFFECT_BUBBLE  = 5;
    TRIGGER_EFFECT_MAX     = 5;

    TRIGGER_EFFECT_POS_CENTER = 0;
    TRIGGER_EFFECT_POS_AREA   = 1;

    ACTIVATE_PLAYERCOLLIDE  = 1;
    ACTIVATE_MONSTERCOLLIDE = 2;
    ACTIVATE_PLAYERPRESS    = 4;
    ACTIVATE_MONSTERPRESS   = 8;
    ACTIVATE_SHOT           = 16;
    ACTIVATE_NOMONSTER      = 32;
    ACTIVATE_CUSTOM         = 255;

    KEY_RED      = 1;
    KEY_GREEN    = 2;
    KEY_BLUE     = 4;
    KEY_REDTEAM  = 8;
    KEY_BLUETEAM = 16;

    TEXTURE_SPECIAL_WATER = DWORD(-1);
    TEXTURE_SPECIAL_ACID1 = DWORD(-2);
    TEXTURE_SPECIAL_ACID2 = DWORD(-3);
    TEXTURE_NONE = DWORD(-4);

    mp2df_wall: array [MP_WALL..MP_LIFTRIGHT] of Integer = (
      PANEL_WALL, PANEL_STEP, PANEL_BACK, PANEL_FORE, PANEL_WATER,
      PANEL_ACID1, PANEL_ACID2, PANEL_LIFTUP, PANEL_LIFTDOWN,
      PANEL_LIFTLEFT, PANEL_LIFTRIGHT
    );

    mp2df_item: array [MP_MEDKIT_SMALL..MP_SUIT] of Byte = (
      ITEM_MEDKIT_SMALL, ITEM_MEDKIT_LARGE, ITEM_ARMOR_GREEN, ITEM_ARMOR_BLUE,
      ITEM_SPHERE_BLUE, ITEM_SPHERE_WHITE, ITEM_INVUL, ITEM_JETPACK,
      ITEM_MEDKIT_BLACK, ITEM_AMMO_BACKPACK, ITEM_AMMO_BULLETS, ITEM_AMMO_BULLETS_BOX,
      ITEM_AMMO_SHELLS, ITEM_AMMO_SHELLS_BOX, ITEM_BOTTLE, ITEM_HELMET,
      ITEM_AMMO_ROCKET, ITEM_AMMO_ROCKET_BOX, ITEM_AMMO_CELL, ITEM_AMMO_CELL_BIG,
      ITEM_WEAPON_SHOTGUN1, ITEM_WEAPON_SHOTGUN2, ITEM_WEAPON_CHAINGUN, ITEM_WEAPON_SAW,
      ITEM_WEAPON_ROCKETLAUNCHER, ITEM_WEAPON_PLASMA, ITEM_WEAPON_BFG, ITEM_WEAPON_SUPERPULEMET,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // unused here
      ITEM_INVIS, ITEM_SUIT
    );

    mp2df_area: array [MP_DMPOINT..MP_BLUEFLAG] of Byte = (
      AREA_DMPOINT, AREA_REDTEAMPOINT, AREA_BLUETEAMPOINT,
      AREA_REDFLAG, AREA_BLUEFLAG
    );

    mp2df_act: array [MP_COLLIDE..MP_NOACT] of Byte = (
      ACTIVATE_PLAYERCOLLIDE, ACTIVATE_PLAYERPRESS, ACTIVATE_SHOT,
      ACTIVATE_NOMONSTER or ACTIVATE_MONSTERCOLLIDE, 0 
    );

    mp2df_trig: array [MP_CLOSEDOOR..MP_EXIT] of Byte = (
      TRIGGER_CLOSETRAP, TRIGGER_OPENDOOR, TRIGGER_DOOR,
      TRIGGER_PRESS, TRIGGER_PRESS, // random, extender
      TRIGGER_ONOFF, TRIGGER_DAMAGE, TRIGGER_TELEPORT, TRIGGER_EXIT
    );

  type
    Tile = record
      t, s, x, y: Integer;
      sx, sy: Single;
      x0, y0, x1, y1: Integer;
      // ------- //
      door: Boolean;   // door
      switch: Boolean; // switchable door
      id: Integer;     // door panel id
      did: Integer;    // switchable door id
    end;

    Texture = record
      name: AnsiString;
      w, h: Integer;
      id: Integer;
      flags: Integer;
    end;

  var
    name, desc, music, sky: AnsiString;
    width, height: Integer;
    textures: array of Texture;
    tiles: array of Tile;

  (* --------- Reader --------- *)

  procedure ReadMap (fname: AnsiString);
    var f: TextFile; i, n: Integer;

    procedure ReadInt (var i: Integer);
      var s: AnsiString;
    begin
      ReadLn(f, s);
      i := StrToInt(s);
    end;

    procedure ReadFloat (var i: Single);
      var s: AnsiString;
    begin
      ReadLn(f, s);
      i := StrToFloat(s);
    end;

  begin
    Assign(f, fname);
    Reset(f);
    ReadLn(f, name);
    ReadLn(f, desc);
    ReadInt(width);
    ReadInt(height);
    ReadLn(f, music);
    ReadLn(f, sky);
    ReadInt(n);
    SetLength(textures, n);
    for i := 1 to n - 1 do
    begin
      ReadLn(f, textures[i].name);
    end;
    i := 0;
    while eof(f) = false do
    begin
      i := Length(tiles);
      SetLength(tiles, i + 1);
      with tiles[i] do
      begin
        ReadInt(t);
        ReadInt(s);
        ReadInt(x);
        ReadInt(y);
        if (t >= 44) and (t <= 48) then
        begin
          ReadFloat(sx);
          ReadFloat(sy);
          if s <> 8 then
          begin
            ReadInt(x0);
            ReadInt(y0);
            if s <> 7 then
            begin
              ReadInt(x1);
              ReadInt(y1);
            end
          end
        end
      end
    end;
    Close(f);
  end;

  (* --------- Analyse --------- *)

  function isCollide (x0, y0, w0, h0, x1, y1, w1, h1: Integer): Boolean;
    var xx0, yy0, xx1, yy1: Integer;
  begin
    xx0 := x0 + w0 - 1;
    yy0 := y0 + h0 - 1;
    xx1 := x1 + w1 - 1;
    yy1 := y1 + h1 - 1;
    result := (xx0 >= x1) and (x0 <= xx1) and (yy0 >= y1) and (y0 <= yy1)
  end;

  procedure Analyse;
    var i, j, t, x, y, w, h, xx, yy, ww, hh: Integer; n: AnsiString; s: PSDL_Surface;
  begin
    if sky = '*NO_BACKGROUND' then sky := '';
    if music = '*NO_MUSIC' then music := '';
    textures[0].w := 16;
    textures[0].h := 16;
    textures[0].id := 0;
    textures[0].flags := PANEL_FLAG_HIDE;
    for i := 1 to High(textures) do
    begin
      n := StringReplace(textures[i].name, '\', '/', [rfReplaceAll]);
      s := IMG_Load(PChar(n));
      if s <> nil then
      begin
        textures[i].w := s.w;
        textures[i].h := s.h;
        SDL_FreeSurface(s);
      end
      else
      begin
        textures[i].w := 16;
        textures[i].h := 16;
        WriteLn('warning: texture ', n, ' not loaded: ', IMG_GetError())
      end;
      textures[i].id := i - 1;
      textures[i].flags := 0;
    end;
    for i := 0 to High(tiles) do
    begin
      tiles[i].id := -1;
      if tiles[i].t in [MP_COLLIDE..MP_NOACT] then
      begin
        t := tiles[i].s;
        if (t in [MP_CLOSEDOOR..MP_DOOR]) or (t >= 101) and (t <= 400) or (t >= 501) and (t <= 800) then
        begin
          x := tiles[i].x0;
          y := tiles[i].y0;
          w := tiles[i].x1 - tiles[i].x0;
          h := tiles[i].y1 - tiles[i].y0;
          for j := 0 to High(tiles) do
          begin
            if tiles[j].t = MP_WALL then
            begin
              xx := tiles[j].x;
              yy := tiles[j].y;
              ww := textures[tiles[j].s].w;
              hh := textures[tiles[j].s].h;
              if isCollide(x, y, w, h, xx, yy, ww, hh) then
              begin
                tiles[j].door := tiles[j].t = MP_WALL;
                if tiles[j].door and ((t = MP_DOOR) or ((t >= 101) and (t <= 400))) then
                  tiles[j].switch := true;
              end
            end
          end
        end
      end
    end;
    j := 0;
    for i := 0 to High(tiles) do
    begin
      tiles[i].did := -1;
      if tiles[i].switch then
      begin
        tiles[i].did := j;
        Inc(j);
      end
    end;
    // TODO merge tiles to panels, but this can be done by df editor so...
  end;

  (* --------- Writer --------- *)

  var
    wrCount: Integer;
    wrFixup: Integer;
    wrTag: Integer;
    wrPanels: Integer;
    wrTriggers: Integer;
    wrX: Integer;

  procedure WriteBytes (f: TFileStream; x: array of Byte);
  begin
    f.Write(x, Length(x));
    Inc(wrCount, Length(x))
  end;

  procedure WriteChars(f: TFileStream; x: array of Char);
    var i: Integer;
  begin
    for i := 0 to High(x) do
    begin
      WriteBytes(f, [Ord(x[i])])
    end
  end;

  procedure WriteAnsiString (f: TFileStream; s: AnsiString; maxlen: Integer);
    var i, len: Integer;
  begin
    Assert(f <> nil);
    Assert(maxlen >= 0);
    len := min(Length(s), maxlen);
    i := 1;
    while i <= len do
    begin
      WriteChars(f, [s[i]]);
      Inc(i)
    end;
    while i <= maxlen do
    begin
      WriteChars(f, [#0]);
      Inc(i)
    end;
  end;

  procedure WriteInt (f: TFileStream; x: Integer);
    var a, b, c, d: Integer;
  begin
    a := x and $FF;
    b := x >> 8 and $FF;
    c := x >> 16 and $FF;
    d := x >> 24 and $FF;
    WriteBytes(f, [a, b, c, d])
  end;

  procedure WriteInt16 (f: TFileStream; x: Integer);
    var a, b: Integer;
  begin
    a := x and $FF;
    b := x >> 8 and $FF;
    WriteBytes(f, [a, b])
  end;

  procedure BeginBlock (f: TFileStream; t: Byte);
  begin
    Assert(wrFixup = 0);
    WriteBytes(f, [t]);
    WriteInt(f, 0);
    wrFixup := f.Position;
    WriteInt(f, -1);
    wrCount := 0
  end;

  procedure EndBlock(f: TFileStream);
    var pos: Integer;
  begin
    pos := f.Position;
    f.Position := wrFixup;
    WriteInt(f, wrCount);
    f.Position := pos;
    wrCount := 0;
    wrFixup := 0
  end;

  procedure WriteHeader (f: TFileStream; name, author, desc, mus, sky: AnsiString; w, h: Integer);
  begin
    BeginBlock(f, 7);
      WriteAnsiString(f, name, 32);
      WriteAnsiString(f, author, 32);
      WriteAnsiString(f, desc, 256);
      WriteAnsiString(f, mus, 64);
      WriteAnsiString(f, sky, 64);
      WriteInt16(f, w);
      WriteInt16(f, h);
    EndBlock(f)
  end;

  procedure WriteTexture (f: TFileStream; name: AnsiString; anim: Byte);
  begin
    WriteAnsiString(f, name, 64);
    WriteBytes(f, [anim]);
  end;

  procedure WritePanel (f: TFileStream; x, y, w, h, tex, typ, alpha, flags: Integer);
  begin
    if (tex < 0) or (tex > High(textures)) then
    begin
      WriteLn('warning: panel ', wrPanels, ' [', x, 'x', y, ':', w, 'x', h, ':typ=', typ, '] have invalid texture id ', tex);
      tex := 0
    end;
    WriteInt(f, x);
    WriteInt(f, y);
    WriteInt16(f, w);
    WriteInt16(f, h);
    WriteInt16(f, tex);
    WriteInt16(f, typ);
    WriteBytes(f, [alpha, flags]);
    Inc(wrPanels)
  end;

  procedure WriteItem (f: TFileStream; x, y: Integer; typ, flags: Byte);
  begin
    WriteInt(f, x);
    WriteInt(f, y);
    WriteBytes(f, [typ, flags]);
  end;

  procedure WriteArea (f: TFileStream; x, y: Integer; typ, dir: Byte);
  begin
    WriteInt(f, x);
    WriteInt(f, y);
    WriteBytes(f, [typ, dir]);
  end;

  procedure WriteEnd (f: TFileStream);
  begin
    BeginBlock(f, 0);
    EndBlock(f)
  end;

  function BoolToInt (x: Boolean): Integer;
  begin
    if x then result := 1 else result := 0
  end;

  procedure BeginTrigger (f: TFileStream; x, y, w, h, enabled, texpan, typ, act, keys: Integer);
  begin
    assert(f <> nil);
    assert(typ in [TRIGGER_EXIT..TRIGGER_MAX]);
    assert(wrTag = 0);
    WriteInt(f, x);
    WriteInt(f, y);
    WriteInt16(f, w);
    WriteInt16(f, h);
    WriteBytes(f, [enabled]);
    WriteInt(f, texpan);
    WriteBytes(f, [typ, act, keys]);
    wrTag := typ
  end;

  procedure EndTrigger (f: TFileStream);
    var i: Integer;
  begin
    assert(f <> nil);
    for i := wrCount mod 148 to 148 - 1 do
    begin
      WriteBytes(f, [0])
    end;
    assert(wrCount mod 148 = 0);
    Inc(wrTriggers);
    wrTag := 0
  end;

  procedure ExitTrigger (f: TFileStream; map: AnsiString);
  begin
    assert(f <> nil);
    assert(wrTag = TRIGGER_EXIT);
    WriteAnsiString(f, map, 16);
    wrTag := 0
  end;

  procedure TeleportTrigger (f: TFileStream; x, y: Integer; d2d, silent: Boolean; dir: Integer);
  begin
    assert(f <> nil);
    assert(wrTag = TRIGGER_TELEPORT);
    WriteInt(f, x);
    WriteInt(f, y);
    WriteBytes(f, [BoolToInt(d2d), BoolToInt(silent), dir]);
    wrTag := 0
  end;

  procedure DoorTrigger (f: TFileStream; panelid: Integer; nosound, d2d: Boolean);
  begin
    assert(f <> nil);
    assert(wrTag in [TRIGGER_OPENDOOR..TRIGGER_TRAP, TRIGGER_LIFTUP..TRIGGER_LIFT]);
    WriteInt(f, panelid);
    WriteBytes(f, [BoolToInt(nosound), BoolToInt(d2d)]);
    wrTag := 0
  end;

  procedure SwitchTrigger (f: TFileStream; x, y, w, h, wait, count, monsterid: Integer; random: Boolean);
  begin
    assert(f <> nil);
    assert(wrTag in [TRIGGER_PRESS, TRIGGER_ON..TRIGGER_ONOFF]);
    WriteInt(f, x);
    WriteInt(f, y);
    WriteInt16(f, w);
    WriteInt16(f, h);
    WriteInt16(f, wait);
    WriteInt16(f, count);
    WriteInt(f, monsterid);
    WriteBytes(f, [BoolToInt(random)]);
    wrTag := 0
  end;

  procedure DamageTrigger (f: TFileStream; damage, interval, typ: Integer);
  begin
    assert(f <> nil);
    assert(wrTag = TRIGGER_DAMAGE);
    WriteInt16(f, damage);
    WriteInt16(f, interval);
    WriteBytes(f, [typ]);
    wrTag := 0
  end;

  function SecToTick (sec: Integer): Integer;
  begin
    result := sec * 1000 div 28;
  end;

  procedure WriteMap (fname: AnsiString);
    var f: TFileStream; i, j, typ, wait: Integer; t: Tile;
  begin
    f := TFileStream.Create(fname, fmCreate);
    WriteLn('magic...');
    WriteBytes(f, [Ord('M'), Ord('A'), Ord('P'), 1]);
    WriteLn('header...');
    WriteHeader(f, name, '', desc, music, sky, width, height);
    WriteLn('textures...');
    BeginBlock(f, 1);
    for i := 1 to High(textures) do
    begin
      WriteTexture(f, ':' + textures[i].name, 0)
    end;
    EndBlock(f);
    WriteLn('panels...');
    BeginBlock(f, 2);
    for i := 0 to High(tiles) do
    begin
      t := tiles[i];
      if t.t in [MP_WALL..MP_LIFTRIGHT] then
      begin
        tiles[i].id := wrPanels;
        if t.door then
          WritePanel(f, t.x, t.y, textures[t.s].w, textures[t.s].h, textures[t.s].id, PANEL_CLOSEDOOR, 0, textures[t.s].flags)
        else if t.t in [MP_LIFTUP..MP_LIFTRIGHT] then
          WritePanel(f, t.x, t.y, 16, 16, 0, mp2df_wall[t.t], 0, PANEL_FLAG_HIDE)
        else if t.t in [MP_WATER..MP_ACID2] then
          WritePanel(f, t.x, t.y, textures[t.s].w, textures[t.s].h, textures[t.s].id, mp2df_wall[t.t], 0, textures[t.s].flags or PANEL_FLAG_WATERTEXTURES)
        else
          WritePanel(f, t.x, t.y, textures[t.s].w, textures[t.s].h, textures[t.s].id, mp2df_wall[t.t], 0, textures[t.s].flags)
      end
    end;
    EndBlock(f);    
    WriteLn('items...');
    BeginBlock(f, 3);
    for i := 0 to High(tiles) do
    begin
      t := tiles[i];
      if t.t in [MP_MEDKIT_SMALL..MP_WEAPON_SUPERPULEMET, MP_INVIS, MP_SUIT] then
        WriteItem(f, t.x, t.y, mp2df_item[t.t], 0)
    end;
    EndBlock(f);
    WriteLn('areas...');
    BeginBlock(f, 4);
    for i := 0 to High(tiles) do
    begin
      t := tiles[i];
      case t.t of
        MP_DMPOINT..MP_BLUETEAMPOINT: WriteArea(f, t.x, t.y + 12, mp2df_area[t.t], 0);
        MP_REDFLAG, MP_BLUEFLAG: WriteArea(f, t.x + 8, t.y - 4, mp2df_area[t.t], 1);
      end
    end;
    EndBlock(f);
    WriteLn('triggers...');
    BeginBlock(f, 6);
    for i := 0 to High(tiles) do
    begin
      t := tiles[i];
      if t.t in [MP_COLLIDE..MP_NOACT] then
      begin
        case t.s of
          MP_EXIT:
            begin
              BeginTrigger(f, t.x, t.y, Round(16 * t.sx), Round(16 * t.sy), 1, -1, TRIGGER_EXIT, mp2df_act[t.t], 0);
              ExitTrigger(f, '');
              EndTrigger(f)
            end;
          MP_TELEPORT:
            begin
              BeginTrigger(f, t.x, t.y, Round(16 * t.sx), Round(16 * t.sy), 1, -1, TRIGGER_TELEPORT, mp2df_act[t.t], 0);
              TeleportTrigger(f, t.x0, t.y0 + 32, true, false, 0);
              EndTrigger(f)
            end;
          MP_CLOSEDOOR, MP_OPENDOOR:
            begin
              for j := 0 to High(tiles) do
              begin
                if tiles[j].door and isCollide(t.x0, t.y0, t.x1 - t.x0, t.y1 - t.y0, tiles[j].x, tiles[j].y, textures[tiles[j].s].w, textures[tiles[j].s].h) then
                begin
                  if tiles[j].switch then
                  begin
                    // sync with MP_DOOR
                    BeginTrigger(f, t.x, t.y, Round(16 * t.sx), Round(16 * t.sy), 1, -1, TRIGGER_PRESS, mp2df_act[t.t], 0);
                    SwitchTrigger(f, tiles[j].did * 32, IfThen(t.s = MP_CLOSEDOOR, -16, -32), 32, 16, 0, 1, 0, false);
                    EndTrigger(f)
                  end
                  else
                  begin
                    BeginTrigger(f, t.x, t.y, Round(16 * t.sx), Round(16 * t.sy), 1, -1, mp2df_trig[t.s], mp2df_act[t.t], 0);
                    DoorTrigger(f, tiles[j].id, false, false);
                    EndTrigger(f);
                  end
                end
              end
            end;
          MP_DOOR, 101..400:
            begin
              wait := IfThen(t.s = MP_DOOR, 0, t.s - 100);
              // button: activate sequence in not locked
              BeginTrigger(f, t.x, t.y, Round(16 * t.sx), Round(16 * t.sy), 1, -1, TRIGGER_PRESS, mp2df_act[t.t], 0);
              SwitchTrigger(f, wrX, -80, 32, 16, 0, 1, 0, false);
              EndTrigger(f);
              // start: activate group + timer
              BeginTrigger(f, wrX, -80, 16, 16, 1, -1, TRIGGER_PRESS, 0, 0);
              SwitchTrigger(f, wrX, -64, 32, 32, 0, 1, 0, false);
              EndTrigger(f);
              // start: lock start
              BeginTrigger(f, wrX + 16, -80, 16, 16, 1, -1, TRIGGER_OFF, 0, 0);
              SwitchTrigger(f, wrX, -80, 16, 16, 0, 1, 0, false);
              EndTrigger(f);
              for j := 0 to High(tiles) do
              begin
                if tiles[j].switch and isCollide(t.x0, t.y0, t.x1 - t.x0, t.y1 - t.y0, tiles[j].x, tiles[j].y, textures[tiles[j].s].w, textures[tiles[j].s].h) then
                begin                      
                  // group: activate both branches
                  BeginTrigger(f, wrX, -64, 16, 16, 1, -1, TRIGGER_PRESS, 0, 0);
                  SwitchTrigger(f, tiles[j].did * 32, -32, 32, 32, 0, 1, 0, false);
                  EndTrigger(f);
                end
              end;
              // timer: wait & activate group
              BeginTrigger(f, wrX, -48, 16, 16, 1, -1, TRIGGER_PRESS, 0, 0);
              SwitchTrigger(f, wrX, -64, 32, 16, SecToTick(wait), 1, 0, false);
              EndTrigger(f);
              // timer: wait & unlock start
              BeginTrigger(f, wrX + 16, -48, 16, 16, 1, -1, TRIGGER_ON, 0, 0);
              SwitchTrigger(f, wrX, -80, 16, 16, SecToTick(wait), 1, 0, false);
              EndTrigger(f);
              Inc(wrX, 32);
            end;
          MP_EXTENDER, MP_RANDOM, MP_SWITCH, 501..800:
            begin
              wait := IfThen(t.s in [MP_EXTENDER, MP_RANDOM, MP_SWITCH], 0, t.s - 500);
              typ := IfThen(t.s in [MP_EXTENDER, MP_RANDOM, MP_SWITCH],  mp2df_trig[t.s], TRIGGER_PRESS);
              BeginTrigger(f, t.x, t.y, Round(16 * t.sx), Round(16 * t.sy), 1, -1, typ, mp2df_act[t.t], 0);
              SwitchTrigger(f, t.x0, t.y0, t.x1 - t.x0, t.y1 - t.y0, SecToTick(wait), 1, 0, t.s = MP_RANDOM);
              EndTrigger(f)
            end;
          MP_DAMAGE:
            begin
              if (t.x = t.x0) and (t.y = t.y0) and (16 * t.sx = t.x1 - t.x0) and (16 * t.sy = t.y1 - t.y0) then
              begin
                BeginTrigger(f, t.x, t.y, t.x1 - t.x0, t.y1 - t.y0, 1, -1, TRIGGER_DAMAGE, mp2df_act[t.t], 0);
                DamageTrigger(f, 666, 0, 0);
                EndTrigger(f)
              end
              else
              begin
                // TODO find non intersectable location for activation
                BeginTrigger(f, t.x, t.y, Round(16 * t.sx), Round(16 * t.sy), 1, -1, TRIGGER_PRESS, mp2df_act[t.t], 0);
                SwitchTrigger(f, t.x0, t.y0, 16, 16, 0, 1, 0, false);
                EndTrigger(f);
                BeginTrigger(f, t.x0, t.y0, t.x1 - t.x0, t.y1 - t.y0, 1, -1, TRIGGER_DAMAGE, 0, 0);
                DamageTrigger(f, 999, 0, 0);
                EndTrigger(f);
                for j := 0 to High(tiles) do
                begin
                  if (j <> i) and isCollide(t.x0, t.y0, 16, 16, tiles[j].x0, tiles[j].y0, tiles[j].x1 - tiles[j].x0, tiles[j].x1 - tiles[j].y0) then
                  begin
                    WriteLn('waring: trigger damage may activate triggers at ', t.x0, 'x', t.y0);
                  end
                end
              end
            end;
          else WriteLn('warning: unknown MP trigger ', t.s)
        end
      end
    end;
    // MP_DOOR intermediate triggers
    for i := 0 to High(tiles) do
    begin
      if tiles[i].switch then
      begin
        // invert state
        BeginTrigger(f, tiles[i].did * 32 + 16, -32, 16, 32, 1, -1, TRIGGER_ONOFF, 0, 0);
        SwitchTrigger(f, tiles[i].did * 32, -32, 16, 32, 0, 1, 0, false);
        EndTrigger(f);
        // open trap
        BeginTrigger(f, tiles[i].did * 32, -32, 16, 16, 1, -1, TRIGGER_OPENDOOR, 0, 0);
        DoorTrigger(f, tiles[i].id, false, false);
        EndTrigger(f);
        // close trap
        BeginTrigger(f, tiles[i].did * 32, -16, 16, 16, 0, -1, TRIGGER_CLOSETRAP, 0, 0);
        DoorTrigger(f, tiles[i].id, false, false);
        EndTrigger(f);
      end
    end;
    EndBlock(f);
    WriteEnd(f);
    f.Free;
  end;

  (* --------- Init --------- *)

  var
    inputFile: AnsiString;
    outputFile: AnsiString = 'MAP01';
    listTextures: Boolean = false;

  procedure PrintTextureList;
    var i: Integer; n: AnsiString;
  begin
    for i := 1 to High(textures) do
    begin
      n := StringReplace(textures[i].name, '\', '/', [rfReplaceAll]);
      WriteLn(n)
    end
  end;

  procedure Help;
  begin
    WriteLn('Usage: mp2df [OPTION] FILE.dlv [OUTPUT]');
    WriteLn('Options:');
    WriteLn('    -l  list textures used on map and exit');
    WriteLn('    -h  show this help');
    Halt(0)
  end;

  procedure ParseArgs;
    var i, n: Integer; done: Boolean; str: AnsiString;
  begin
    i := 1; done := false;
    while (i <= ParamCount) and (not done) do
    begin
      str := ParamStr(i);
      done := (Length(str) = 0) or (str[1] <> '-');
      if not done then
      begin
        case str of
          '-l': listTextures := true;
          '-h', '-?': Help;
        else
          WriteLn('mp2df: unknown argument ', str);
          Halt(1)
        end;
        Inc(i)
      end
    end;
    n := ParamCount - i + 1;
    if n = 1 then
    begin
      inputFile := ParamStr(i);
    end
    else if (n = 2) and (not listTextures) then
    begin
      inputFile := ParamStr(i);
      outputFile := ParamStr(i + 1);
    end
    else
    begin
      WriteLn('mp2df: you may specify input file and output file only, use -h to know more');
      Halt(1)
    end;
    if inputFile = '' then
    begin
      WriteLn('mp2df: empty input file path');
      Halt(1);
    end;
    if outputFile = '' then
    begin
      WriteLn('mp2df: empty output file path');
      Halt(1);
    end
  end;

begin
  ParseArgs;
  ReadMap(inputFile);
  if listTextures then
  begin
    PrintTextureList
  end
  else
  begin
    Analyse;
    WriteMap(outputFile)
  end;
  Halt(0)
end.
