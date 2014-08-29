unit mainForm;

interface

uses 
  w3panel, w3time, W3System, W3Graphics, W3Components, W3Forms, w3Panel,
  W3Fonts, W3Borders, W3Image, W3Application, W3Button, W3Label, w3dialogs,
  w3effects, w3memo,
  caselist,
  qtxEffects,
  qtxScrollController,
  qtxUtils,
  qtxlabel,
  qtxscrolltext;

type


  TCBDialogInfo = Class(TObject)
  private
    FBlocker:   TW3BlockBox;
    FBox:       TW3Panel;
    FCancel:    TCBGlyphButton;
    FPost:      TCBGlyphButton;
    FEditor:    TW3Memo;
    FTitle:     TQTXLabel;
  public
    property    Editor:TW3Memo read FEditor;
    Property    BackgroundBlocker:TW3BlockBox read FBlocker;
    Property    Panel:TW3Panel read FBox;
    property    CancelButton:TCBGlyphButton read FCancel;
    Property    PostButton:TCBGlyphButton read FPost;

    Constructor Create;virtual;
    Destructor  Destroy;Override;
  End;

  TForm1=class(TW3form)
  private
    {$I 'mainForm:intf'}
    FList:    TCaseBookList;
    FPanel:   TCBPanel;
    FHomeButton: TCBGlyphButton;
    FProfileButton: TCBGlyphButton;
    FNewButton:TCBGlyphButton;
    FMore:      TCBGlyphButton;
    FFirst:   Boolean = true;
    Procedure Populate(const item:TCBNewsItem);
    Procedure setupItems;
  protected
    procedure InitializeForm; override;
    procedure InitializeObject; override;
    procedure Resize; override;
    procedure FormActivated; override;
  public

  end;

implementation

{ TForm1}
uses casebook, W3MouseTouch;

Constructor TCBDialogInfo.Create;
var
  dx: Integer;
  dy: Integer;
  wd: Integer;
Begin
  inherited Create;

  FBlocker := TW3BlockBox.Create(Application.Display);
  FBlocker.SetBounds(0,0,Application.Display.Width,Application.Display.Height);
  FBlocker.BringToFront;

  FBox:=TW3Panel.Create(FBlocker);
  FBox.SetBounds(10,20,300,280);
  FBox.moveTo((application.display.clientwidth div 2) - FBox.width div 2,
    (application.display.clientHeight div 2) - FBox.height div 2);

  FEditor:=TW3Memo.Create(FBox);
  FEditor.SetBounds(10,40,FBox.ClientWidth-20,(FBox.ClientHeight-20) - 80);

  FTitle:=TQTXLabel.Create(FBox);
  FTitle.MoveTo(10,10);
  FTitle.Caption:='Add new post';

  dy:=FBox.ClientHeight-40;
  wd:=((FBox.ClientWidth - 40) div 2) - 20;
  Fpost:=TCBGlyphButton.Create(FBox);
  Fpost.setBounds(10,dy,wd,26);
  FPost.text.Autosize:=False;
  FPost.text.height:=16;
  FPost.Text.Caption:='Post';
  FPost.glyph.innerHTML:='<i class="fa fa-bolt fa-2x">';
  FPost.LayoutChildren;
  FPost.Glyph.height:=26;

  dx:=(FBox.ClientWidth - 10) - wd;
  FCancel:=TCBGlyphButton.Create(FBox);
  FCancel.setBounds(dx,dy,wd,26);
  FCancel.text.Autosize:=False;
  FCancel.text.height:=16;
  FCancel.text.caption:='Cancel';
  FCancel.glyph.innerHTML:='<i class="fa fa-times fa-2x">';
  FCancel.LayoutChildren;
  FCancel.Glyph.height:=26;

  FCancel.OnMouseTouchRelease:=Procedure (Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer)
    Begin
      FBox.fxZoomOut(0.3, procedure ()
      Begin
        self.free;
      end);
    end;

  FBox.fxZoomIn(0.3);

end;

Destructor TCBDialogInfo.Destroy;
Begin
  FPost.free;
  FTitle.free;
  FEditor.free;
  FBox.free;
  FBlocker.free;
  inherited;
end;

//#############################################################################
// FORM
//#############################################################################

procedure TForm1.FormActivated;
Begin
  inherited;
  writeln('Form1 activated');
  TApplication(application).Header.Title.Caption:='CaseBook';
  TApplication(application).Header.Backbutton.visible:=False;

  if FFirst then
  Begin
    FFirst:=False;
    w3_callback( procedure ()
      begin
        if width>320 then
        Begin
          application.ShowDialog('Display warning',#"
            This application was built for<br>
            iPhone 5. Your display is presently<br>
            not compatible with the layout",aoOK);
        end;
      end,
      1000);
  end;

end;

procedure TForm1.InitializeForm;
var
  mLabel: TQTXLabel;
begin
  inherited;

  FList.content.handle.style['background-color']:='transparent';
  Flist.handle.style['background-color']:='transparent';

  TQTXTools.ExecuteOnElementReady(self.handle, procedure ()
    begin
      w3_callback( procedure ()
        Begin
          setupItems;
        end,
        500);

    end);

end;

procedure TForm1.InitializeObject;
var
  mButton:  TCBGlyphButton;
  mDialog:  TCBDialogInfo;
begin
  inherited;
  {$I 'mainForm:impl'}
  FList:=TCaseBookList.Create(self);

  FPanel:=TCBPanel.Create(self);
  FPanel.Height:=200;
  FPanel.BeginUpdate;
  try

    FPanel.styleclass:='tardis';
    FPanel.background.fromColor(clWhite);
    FPanel.Visible:=False;

    FNewButton:=TCBGlyphButton.Create(FPanel);
    FNewButton.BeginUpdate;
    try
      FNewButton.left:=2;
      FNewButton.width:=80;
      FNewButton.height:=36;
      FNewButton.Text.Caption:='Post';
      FNewButton.Glyph.innerHTML:='<i class="fa fa-file fa-2x">';
      FNewButton.OnMouseTouchRelease:=Procedure (Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer)
        Begin
          mDialog:=TCBDialogInfo.Create;
          mDialog.PostButton.OnMouseTouchRelease:=Procedure (Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer)
            begin
              (* zoom out dialog and cleanup *)
              mDialog.Panel.fxZoomOut(0.3, procedure ()
              var
                mText:  String;
              begin
                (* Capture message text, then release dialog *)
                mText:=trim(mDialog.Editor.text);
                mDialog.free;
                showmessage('You posted a message:' + #13 + #13 + mText);
              end);
            end;
        end;
    finally
      FNewButton.EndUpdate;
    end;

    FProfileButton:=TCBGlyphButton.Create(FPanel);
    FProfileButton.BeginUpdate;
    try
      FProfileButton.left:=84;
      FProfilebutton.width:=80;
      FProfilebutton.height:=36;
      Fprofilebutton.Text.Caption:='Profile';
      FProfilebutton.Glyph.innerHTML:='<i class="fa fa-user fa-2x">';
      FProfilebutton.OnMouseTouchRelease:=Procedure (Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer)
        Begin
          Application.gotoForm('FormProfile',feFromRight);
        end;
    finally
      FProfileButton.EndUpdate;
    end;

    FHomeButton:=TCBGlyphButton.Create(FPanel);
    FHomeButton.BeginUpdate;
    try
      FHomeButton.left:=166;
      FHomeButton.width:=86;
      FHomeButton.height:=36;
      FHomeButton.Text.Caption:='Logout';
      FHomeButton.Text.Autosize:=False;
      FHomeButton.text.Height:=20;
      FHomeButton.LayoutChildren;

      FHomeButton.Glyph.innerHTML:='<i class="fa fa-arrow-circle-left fa-2x">';
      FHomeButton.OnMouseTouchRelease:=Procedure (Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer)
        Begin
          w3_callback( procedure ()
          begin
            TApplication(application).ShowDialog('<li class="fa fa-warning">&nbsp</li>Logout?',
            'Are you sure you wish to log<br>out of this application?',aoYesNo);
            application.OnDialogSelect:=Procedure (Sender: TObject; aResult: TW3AlertResult)
              Begin
                if aResult=roYes then
                begin
                  TApplication(application).FormLogin.ResetState;
                  application.gotoForm('FormLogin',feToLeft);
                end;
            end;
          end,
          200);

        end;
    finally
      FHomeButton.EndUpdate;
    end;

    FMore:=TCBGlyphButton.Create(FPanel);
    FMore.SetBounds(255 + 26,4,36 - 2,36);
    FMore.Text.Visible:=False;
    FMore.glyph.handle.style['color']:='#6B87C4';
    FMore.Glyph.InnerHTML:='<i class="fa fa-bars fa-2x">';

  finally
    FPanel.EndUpdate;
    FPanel.fxFadeIn(0.1);
  end;

end;
 
procedure TForm1.Resize;
var
  wd: Integer;
begin
  inherited;
  if handle.ready then
  Begin
    FPanel.setBounds(0,0,clientWidth,44);

    FHomeButton.top:=(FPanel.ClientHeight div 2) - (FHomeButton.height div 2);
    FProfileButton.top:=(FPanel.ClientHeight div 2) - (FProfileButton.Height div 2);
    FNewButton.top:=(FPanel.ClientHeight div 2) - (FNewButton.Height div 2);


    wd:=TInteger.EnsureRange(Clientwidth-4,0,320);
    FList.setBounds(2,FPanel.Height,wd,clientHeight-FPanel.Height);
  end;
end;


Procedure TForm1.Populate(const item:TCBNewsItem);
var
  mValue: Integer;
Begin
  if (TCBNewsItem.Index mod 5)=0 then
  Begin
  item.Image.LoadFromURL('res/avatar01.jpg');
  item.title.Caption:='<b>Smart Mobile Studio</b>';
  Item.TimeInfo.caption:='SMARTMOBILESTUDIO.COM wrote @ ' + TimeToStr(now);
  item.Text.Caption:=#'The market has spoken: single source, multi-platform,
  HTML5 based, client-server application development is the future.
  Finally a “write once, run anywhere” solution that delivers!
  Presenting <a href="http://www.smartmobilestudio.com">Smart Mobile Studio</a> ..';
  item.Height:=128 + 6 + 4;
  item.text.Background.FromColor(RGBToColor($EF,$EF,$EF));
  end else
  if (TCBNewsItem.Index mod 5)=1 then
  Begin
  item.Image.LoadFromURL('res/avatar02.jpg');
  item.title.Caption:='<b>Get the Asssassins-Creed hoodie</b>';
  Item.TimeInfo.caption:='ASSASSINSHOODIES.COM wrote @ ' + TimeToStr(now);
  item.Text.Caption:='Absolute must-have in any mans wardrobe.'
    +'Only $26.90 USD + Free Shipping!<br>'
    +'Get it now: <a href="http://bit.ly/Assassins-I">http://bit.ly/Assassins-I</a> '
    +'Materials: 80% Polyester, 20% Cotton<br>'
    +'Style: With Hood '
    +'Features: Anti-Pilling, Anti-Shrink, Breathable';
  item.Height:=128 + 16 + 6 + 4;
  item.text.Background.FromColor(RGBToColor($EF,$EF,$EF));
  end else
  if (TCBNewsItem.Index mod 5)=2 then
  Begin
  item.Image.LoadFromURL('res/avatar03.png');
  item.title.Caption:='<b>Classic Platformer Another World Coming to PS4, PS3</b>';
  Item.TimeInfo.caption:='PLAYSTATION.COM wrote @ ' + TimeToStr(now);
  item.Text.Caption:=#'<a href="http://blog.us.playstation.com/2014/06/17/classic-platformer-another-world-is-coming-to-ps4-next-week/">Another World</a> is confirmed for launch on July 8th for PS4, PS3,
          and PS Vita — including three-way cross buy support across
          those platforms. We apologize for any confusion the previous
          version of this post may have caused!';
  item.Height:=132 + 6 + 4;
  item.text.Background.FromColor(RGBToColor($EF,$EF,$EF));
  end else
  if (TCBNewsItem.Index mod 5)=3 then
  Begin
  item.Image.LoadFromURL('res/avatar04.jpg');
  item.title.Caption:='<b>Delphi XE6</b>';
  Item.TimeInfo.caption:='EMBARCADERO.COM wrote @ ' + TimeToStr(now);
  item.Text.Caption:=#'
      Embarcadero Delphi XE6 is the fastest way to develop true native
      applications for Windows, Mac, Android and iOS from a single codebase.
      Develop multi-device applications 5x to 20x faster with a proven visual
      development environment, component framework with source code and full
      access to platform APIs. Extend your existing Windows applications
      with mobile companion apps.';
  item.Height:=188 + 4 + 16 + 4;
  item.text.Background.FromColor(RGBToColor($EF,$EF,$EF));
  end else
  if (TCBNewsItem.Index mod 5)=4 then
  begin
  item.Image.LoadFromURL('res/avatar05.png');
  item.title.Caption:='<b>Create native iOS and Android apps in C#</b>';
  Item.TimeInfo.caption:='XAMARIN.COM wrote @ ' + TimeToStr(now);
  item.Text.Caption:=#'We created <a href="http://xamarin.com/">Xamarin</a> because we knew there had to be a
    better way – a better way to design apps, to develop apps, to integrate
    apps, to test apps and more. We’re developers, so we know what developers
    want from mobile app development software: a modern programming language,
    code sharing across all platforms, prebuilt backend connectors and
    no-compromise native user interfaces.';
  item.Height:=188 + 16 + 4 + 4;
  item.text.Background.FromColor(RGBToColor($EF,$EF,$EF));
  end;
  TCBNewsItem.Index:=TCBNewsItem.Index + 1;
end;

Procedure TForm1.setupItems;
var
  x:  Integer;
  dy:Integer;
  mItem:  TCBNewsItem;
begin
  dy:=4;
  for x:=1 to 10 do
  begin
    mItem:=TCBNewsItem.Create(FList.Content);
    mItem.setBounds(2,dy,FList.Content.ClientWidth-4,100);
    Populate(mItem);
    inc(dy,mItem.Height + 4);
  end;
  FList.Content.Height:=dy + 16;
  FList.ScrollApi.Refresh;
end;

 
end.