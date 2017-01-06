// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import UIKit

/** A wrapper class for Objective-C compatibility. */
public extension Iconic {

    /** The icon font's family name. */
    @objc class var fontAwesomeIconFamilyName: NSString {
        return FontAwesomeIcon.familyName as NSString
    }
    /** The icon font's total count of available icons. */
    @objc class var fontAwesomeIconCount: Int {
        return FontAwesomeIcon.count
    }
    /**
     Returns the icon font object for the specified size.

     - parameter size: The size (in points) to which the font is scaled.
     */
    @objc class func fontAwesomeIconFont(ofSize size: CGFloat) -> UIFont {
        return FontAwesomeIcon.font(ofSize: size)
    }

    /**
     Returns the icon as an attributed string with the given pointSize and color.

     - parameter icon: The icon type.
     - parameter pointSize: The size of the font.
     - parameter color: The tint color of the font.
     */
    @objc class func attributedString(withIcon icon: FontAwesomeIcon, pointSize: CGFloat, color: UIColor?) -> NSAttributedString {
        return icon.attributedString(ofSize: pointSize, color: color)
    }

    /**
     Returns the icon as an attributed string with the given pointSize, color and padding.

     - parameter icon: The icon type.
     - parameter pointSize: The size of the font.
     - parameter color: The tint color of the font.
     - parameter edgeInsets: The edge insets to be used as horizontal and vertical padding.
     */
    @objc class func attributedString(withIcon icon: FontAwesomeIcon, pointSize: CGFloat, color: UIColor?, edgeInsets: UIEdgeInsets) -> NSAttributedString {
        return icon.attributedString(ofSize: pointSize, color: color, edgeInsets: edgeInsets)
    }
    /**
     Returns the icon as an image with the given size and color.

     - parameter icon: The icon type.
     - parameter size: The size of the image, in points.
     - parameter color: A tint color for the image.
     */
    @objc class func image(withIcon icon: FontAwesomeIcon, size: CGSize, color: UIColor?) -> UIImage {
        return icon.image(ofSize: size, color: color)
    }

    /**
     Returns the icon as an image with the given size and color.

     - parameter icon: The icon type.
     - parameter size: The size of the image, in points.
     - parameter color: The tint color of the image.
     - parameter edgeInsets: The edge insets to be used as padding values.
     */
    @objc class func image(withIcon icon: FontAwesomeIcon, size: CGSize, color: UIColor?, edgeInsets: UIEdgeInsets) -> UIImage {
        return icon.image(ofSize: size, color: color, edgeInsets: edgeInsets)
    }

    /**
     Registers the icon font with the font manager.
     Note: an exception will be thrown if the resource (ttf/otf) font file is not found in the bundle.
     */
    @objc class func registerFontAwesomeIcon() {
        FontAwesomeIcon.register()
    }
    /**
     Unregisters the icon font from the font manager.
     */
    @objc class func unregisterFontAwesomeIcon() {
        FontAwesomeIcon.unregister()
    }
}

#if os(iOS) || os(tvOS)

public extension UIBarButtonItem {
    /**
     Initializes a new item using the specified icon and other properties.
     - parameter icon: The icon to be used as image.
     - parameter size: The size of the image, in points.
     - parameter target: The object that receives the action message.
     - parameter action: The action to send to target when this item is selected.
     */
    convenience init(withIcon icon: FontAwesomeIcon, size: CGSize, target: AnyObject?, action: Selector) {
        let image = icon.image(ofSize: size, color: .black)
        self.init(image: image, style: .plain, target: target, action: action)
    }
}

public extension UITabBarItem {
    /**
     Initializes a new item using the specified icon and other properties.
     The tag is automatically assigned using the icon's raw integer value.
     - parameter icon: The icon to be used as image.
     - parameter size: The size of the image, in points.
     - parameter title: The item's title. If nil, a title is not displayed.
     */
    convenience init(withIcon icon: FontAwesomeIcon, size: CGSize, title: String?) {
        let image = icon.image(ofSize: size, color: .black)
        self.init(title: title, image: image, tag: icon.rawValue)
    }
}

public extension UIButton {
    /**
     Sets the icon to use for the specified state.
     - parameter icon: The icon to be used as image.
     - parameter size: The size of the image, in points.
     - parameter color: The color of the image.
     - parameter state: The state that uses the specified title. The values are described in UIControlState.
     */
    func setIconImage(withIcon icon: FontAwesomeIcon, size: CGSize, color: UIColor?, forState state: UIControlState) {
        let image = icon.image(ofSize: size, color: color ?? .black)
        setImage(image, for: state)
    }
}

#endif

/** A list with available icon glyphs from the icon font. */
@objc public enum FontAwesomeIcon: Int {
    case _279Icon
    case _283Icon
    case _303Icon
    case _312Icon
    case _317Icon
    case _329Icon
    case _334Icon
    case _335Icon
    case _366Icon
    case _372Icon
    case _374Icon
    case _376Icon
    case _378Icon
    case _380Icon
    case _382Icon
    case _383Icon
    case _384Icon
    case _385Icon
    case _386Icon
    case _387Icon
    case _388Icon
    case _389Icon
    case _392Icon
    case _393Icon
    case _395Icon
    case _396Icon
    case _397Icon
    case _398Icon
    case _399Icon
    case _400Icon
    case _402Icon
    case _403Icon
    case _404Icon
    case _406Icon
    case _407Icon
    case _408Icon
    case _409Icon
    case _410Icon
    case _411Icon
    case _412Icon
    case _413Icon
    case _414Icon
    case _415Icon
    case _416Icon
    case _417Icon
    case _418Icon
    case _419Icon
    case _422Icon
    case _423Icon
    case _424Icon
    case _425Icon
    case _426Icon
    case _427Icon
    case _428Icon
    case _429Icon
    case _430Icon
    case _431Icon
    case _432Icon
    case _433Icon
    case _434Icon
    case _438Icon
    case _439Icon
    case _443Icon
    case _444Icon
    case _445Icon
    case _446Icon
    case _447Icon
    case _448Icon
    case _449Icon
    case _451Icon
    case _452Icon
    case _453Icon
    case _454Icon
    case _455Icon
    case _456Icon
    case _457Icon
    case _458Icon
    case _459Icon
    case _460Icon
    case _461Icon
    case _462Icon
    case _463Icon
    case _464Icon
    case _466Icon
    case _467Icon
    case _469Icon
    case _470Icon
    case _471Icon
    case _472Icon
    case _473Icon
    case _474Icon
    case _475Icon
    case _476Icon
    case _478Icon
    case _479Icon
    case _480Icon
    case _481Icon
    case _482Icon
    case _483Icon
    case _484Icon
    case _485Icon
    case _486Icon
    case _487Icon
    case _488Icon
    case _489Icon
    case _490Icon
    case _491Icon
    case _492Icon
    case _493Icon
    case _494Icon
    case _496Icon
    case _498Icon
    case _499Icon
    case _500Icon
    case _501Icon
    case _502Icon
    case _503Icon
    case _504Icon
    case _505Icon
    case _506Icon
    case _507Icon
    case _508Icon
    case _509Icon
    case _511Icon
    case _512Icon
    case _513Icon
    case _514Icon
    case _515Icon
    case _516Icon
    case _517Icon
    case _518Icon
    case _519Icon
    case _520Icon
    case _521Icon
    case _522Icon
    case _523Icon
    case _524Icon
    case _525Icon
    case _526Icon
    case _527Icon
    case _528Icon
    case _529Icon
    case _530Icon
    case _531Icon
    case _532Icon
    case _533Icon
    case _534Icon
    case _535Icon
    case _536Icon
    case _537Icon
    case _538Icon
    case _539Icon
    case _540Icon
    case _541Icon
    case _542Icon
    case _543Icon
    case _544Icon
    case _545Icon
    case _546Icon
    case _547Icon
    case _548Icon
    case _549Icon
    case _550Icon
    case _551Icon
    case _552Icon
    case _553Icon
    case _554Icon
    case _555Icon
    case _556Icon
    case _557Icon
    case _558Icon
    case _559Icon
    case _560Icon
    case _561Icon
    case _562Icon
    case _563Icon
    case _564Icon
    case _565Icon
    case _566Icon
    case _567Icon
    case _568Icon
    case _569Icon
    case _572Icon
    case _574Icon
    case _575Icon
    case _576Icon
    case _577Icon
    case _578Icon
    case _579Icon
    case _580Icon
    case _581Icon
    case _582Icon
    case _583Icon
    case _584Icon
    case _585Icon
    case _586Icon
    case _587Icon
    case _588Icon
    case _589Icon
    case _590Icon
    case _591Icon
    case _592Icon
    case _593Icon
    case _594Icon
    case _595Icon
    case _596Icon
    case _597Icon
    case _598Icon
    case _602Icon
    case _603Icon
    case _604Icon
    case _607Icon
    case _608Icon
    case _609Icon
    case _610Icon
    case _611Icon
    case _612Icon
    case _613Icon
    case _614Icon
    case _615Icon
    case _616Icon
    case _617Icon
    case _618Icon
    case _619Icon
    case _620Icon
    case _621Icon
    case _622Icon
    case _623Icon
    case _624Icon
    case _625Icon
    case _626Icon
    case _627Icon
    case _628Icon
    case _629Icon
    case _698Icon
    case adjustIcon
    case adnIcon
    case alignCenterIcon
    case alignJustifyIcon
    case alignLeftIcon
    case alignRightIcon
    case ambulanceIcon
    case anchorIcon
    case androidIcon
    case angleDownIcon
    case angleLeftIcon
    case angleRightIcon
    case angleUpIcon
    case appleIcon
    case archiveIcon
    case arrowCircleAltLeftIcon
    case arrowDownIcon
    case arrowLeftIcon
    case arrowRightIcon
    case arrowUpIcon
    case asteriskIcon
    case backwardIcon
    case banCircleIcon
    case barChartIcon
    case barcodeIcon
    case beakerIcon
    case beerIcon
    case bellIcon
    case bellAltIcon
    case bitbucketSignIcon
    case boldIcon
    case boltIcon
    case bookIcon
    case bookmarkIcon
    case bookmarkEmptyIcon
    case briefcaseIcon
    case btcIcon
    case bugIcon
    case buildingIcon
    case bullhornIcon
    case bullseyeIcon
    case calendarIcon
    case calendarEmptyIcon
    case cameraIcon
    case cameraRetroIcon
    case caretDownIcon
    case caretLeftIcon
    case caretRightIcon
    case caretUpIcon
    case certificateIcon
    case checkIcon
    case checkEmptyIcon
    case checkMinusIcon
    case checkSignIcon
    case chevronDownIcon
    case chevronLeftIcon
    case chevronRightIcon
    case chevronSignDownIcon
    case chevronSignLeftIcon
    case chevronSignRightIcon
    case chevronSignUpIcon
    case chevronUpIcon
    case circleIcon
    case circleArrowDownIcon
    case circleArrowLeftIcon
    case circleArrowRightIcon
    case circleArrowUpIcon
    case circleBlankIcon
    case cloudIcon
    case cloudDownloadIcon
    case cloudUploadIcon
    case codeIcon
    case codeForkIcon
    case coffeeIcon
    case cogIcon
    case cogsIcon
    case collapseIcon
    case collapseAltIcon
    case collapseTopIcon
    case columnsIcon
    case commentIcon
    case commentAltIcon
    case commentsIcon
    case commentsAltIcon
    case compassIcon
    case copyIcon
    case creditCardIcon
    case cropIcon
    case css3Icon
    case cutIcon
    case dashboardIcon
    case desktopIcon
    case dotCircleAltIcon
    case doubleAngleDownIcon
    case doubleAngleLeftIcon
    case doubleAngleRightIcon
    case doubleAngleUpIcon
    case downloadIcon
    case downloadAltIcon
    case dribbleIcon
    case dropboxIcon
    case editIcon
    case editSignIcon
    case ejectIcon
    case ellipsisHorizontalIcon
    case ellipsisVerticalIcon
    case envelopeIcon
    case envelopeAltIcon
    case eurIcon
    case exchangeIcon
    case exclamationIcon
    case exclamationSignIcon
    case expandAltIcon
    case externalLinkIcon
    case eyeCloseIcon
    case eyeOpenIcon
    case f0feIcon
    case f171Icon
    case f1a1Icon
    case f1a4Icon
    case f1abIcon
    case f1f3Icon
    case f1fcIcon
    case f210Icon
    case f212Icon
    case f260Icon
    case f261Icon
    case f263Icon
    case f27eIcon
    case facebookIcon
    case facebookSignIcon
    case facetimeVideoIcon
    case fastBackwardIcon
    case fastForwardIcon
    case femaleIcon
    case fighterJetIcon
    case fileIcon
    case fileAltIcon
    case fileTextIcon
    case fileTextAltIcon
    case filmIcon
    case filterIcon
    case fireIcon
    case fireExtinguisherIcon
    case flagIcon
    case flagAltIcon
    case flagCheckeredIcon
    case flickrIcon
    case folderCloseIcon
    case folderCloseAltIcon
    case folderOpenIcon
    case folderOpenAltIcon
    case fontIcon
    case foodIcon
    case forwardIcon
    case foursquareIcon
    case frownIcon
    case fullscreenIcon
    case gamepadIcon
    case gbpIcon
    case giftIcon
    case githubIcon
    case githubAltIcon
    case githubSignIcon
    case gittipIcon
    case glassIcon
    case globeIcon
    case googlePlusIcon
    case googlePlusSignIcon
    case groupIcon
    case hSignIcon
    case handDownIcon
    case handLeftIcon
    case handRightIcon
    case handUpIcon
    case hddIcon
    case headphonesIcon
    case heartIcon
    case heartEmptyIcon
    case homeIcon
    case hospitalIcon
    case html5Icon
    case inboxIcon
    case indentLeftIcon
    case indentRightIcon
    case infoSignIcon
    case inrIcon
    case instagramIcon
    case italicIcon
    case jpyIcon
    case keyIcon
    case keyboardIcon
    case krwIcon
    case laptopIcon
    case leafIcon
    case legalIcon
    case lemonIcon
    case lessequalIcon
    case levelDownIcon
    case levelUpIcon
    case lightBulbIcon
    case linkIcon
    case linkedinIcon
    case linkedinSignIcon
    case linuxIcon
    case listIcon
    case listAltIcon
    case locationArrowIcon
    case lockIcon
    case longArrowDownIcon
    case longArrowLeftIcon
    case longArrowRightIcon
    case longArrowUpIcon
    case magicIcon
    case magnetIcon
    case maleIcon
    case mapMarkerIcon
    case maxcdnIcon
    case medkitIcon
    case mehIcon
    case microphoneIcon
    case microphoneOffIcon
    case minusIcon
    case minusSignIcon
    case minusSignAltIcon
    case mobilePhoneIcon
    case moneyIcon
    case moveIcon
    case musicIcon
    case offIcon
    case okIcon
    case okCircleIcon
    case okSignIcon
    case olIcon
    case paperClipIcon
    case pasteIcon
    case pauseIcon
    case pencilIcon
    case phoneIcon
    case phoneSignIcon
    case pictureIcon
    case pinterestIcon
    case pinterestSignIcon
    case planeIcon
    case playIcon
    case playCircleIcon
    case playSignIcon
    case plusIcon
    case plusSignIcon
    case plusSquareOIcon
    case printIcon
    case pushpinIcon
    case puzzlePieceIcon
    case qrcodeIcon
    case questionIcon
    case questionSignIcon
    case quoteLeftIcon
    case quoteRightIcon
    case randomIcon
    case refreshIcon
    case removeIcon
    case removeCircleIcon
    case removeSignIcon
    case renrenIcon
    case reorderIcon
    case repeatIcon
    case replyIcon
    case replyAllIcon
    case resizeFullIcon
    case resizeHorizontalIcon
    case resizeSmallIcon
    case resizeVerticalIcon
    case retweetIcon
    case roadIcon
    case rocketIcon
    case rssIcon
    case rubIcon
    case saveIcon
    case screenshotIcon
    case searchIcon
    case shareIcon
    case shareAltIcon
    case shareSignIcon
    case shieldIcon
    case shoppingCartIcon
    case signBlankIcon
    case signalIcon
    case signinIcon
    case signoutIcon
    case sitemapIcon
    case skypeIcon
    case smileIcon
    case sortIcon
    case sortByAlphabetIcon
    case sortByAttributesIcon
    case sortByAttributesAltIcon
    case sortByOrderIcon
    case sortByOrderAltIcon
    case sortDownIcon
    case sortUpIcon
    case spinnerIcon
    case stackExchangeIcon
    case stackexchangeIcon
    case starIcon
    case starEmptyIcon
    case starHalfIcon
    case starHalfEmptyIcon
    case stepBackwardIcon
    case stepForwardIcon
    case stethoscopeIcon
    case stopIcon
    case strikethroughIcon
    case subscriptIcon
    case suitcaseIcon
    case sunIcon
    case superscriptIcon
    case tableIcon
    case tabletIcon
    case tagIcon
    case tagsIcon
    case tasksIcon
    case terminalIcon
    case textHeightIcon
    case textWidthIcon
    case thIcon
    case thLargeIcon
    case thListIcon
    case thumbsDownAltIcon
    case thumbsUpAltIcon
    case ticketIcon
    case timeIcon
    case tintIcon
    case trashIcon
    case trelloIcon
    case trophyIcon
    case truckIcon
    case tumblrIcon
    case tumblrSignIcon
    case twitterIcon
    case twitterSignIcon
    case ulIcon
    case umbrellaIcon
    case underlineIcon
    case undoIcon
    case uniF1A0Icon
    case uniF1B1Icon
    case uniF1C0Icon
    case uniF1C1Icon
    case uniF1D0Icon
    case uniF1D1Icon
    case uniF1D2Icon
    case uniF1D5Icon
    case uniF1D6Icon
    case uniF1D7Icon
    case uniF1E0Icon
    case uniF1F0Icon
    case uniF280Icon
    case uniF281Icon
    case uniF285Icon
    case uniF286Icon
    case uniF2A0Icon
    case uniF2A1Icon
    case uniF2A2Icon
    case uniF2A3Icon
    case uniF2A4Icon
    case uniF2A5Icon
    case uniF2A6Icon
    case uniF2A7Icon
    case uniF2A8Icon
    case uniF2A9Icon
    case uniF2AAIcon
    case uniF2ABIcon
    case uniF2ACIcon
    case uniF2ADIcon
    case uniF2AEIcon
    case uniF2B0Icon
    case uniF2B1Icon
    case uniF2B2Icon
    case uniF2B3Icon
    case uniF2B4Icon
    case uniF2B5Icon
    case uniF2B6Icon
    case uniF2B7Icon
    case uniF2B8Icon
    case uniF2B9Icon
    case uniF2BAIcon
    case uniF2BBIcon
    case uniF2BCIcon
    case uniF2BDIcon
    case uniF2BEIcon
    case uniF2C0Icon
    case uniF2C1Icon
    case uniF2C2Icon
    case uniF2C3Icon
    case uniF2C4Icon
    case uniF2C5Icon
    case uniF2C6Icon
    case uniF2C7Icon
    case uniF2C8Icon
    case uniF2C9Icon
    case uniF2CAIcon
    case uniF2CBIcon
    case uniF2CCIcon
    case uniF2CDIcon
    case uniF2CEIcon
    case uniF2D0Icon
    case uniF2D1Icon
    case uniF2D2Icon
    case uniF2D3Icon
    case uniF2D4Icon
    case uniF2D5Icon
    case uniF2D6Icon
    case uniF2D7Icon
    case uniF2D8Icon
    case uniF2D9Icon
    case uniF2DAIcon
    case uniF2DBIcon
    case uniF2DCIcon
    case uniF2DDIcon
    case uniF2DEIcon
    case uniF2E0Icon
    case uniF2E1Icon
    case uniF2E2Icon
    case uniF2E3Icon
    case uniF2E4Icon
    case uniF2E5Icon
    case uniF2E6Icon
    case uniF2E7Icon
    case uniF2E9Icon
    case uniF2EAIcon
    case uniF2EBIcon
    case uniF2ECIcon
    case uniF2EDIcon
    case uniF2EEIcon
    case unlinkIcon
    case unlockIcon
    case unlockAltIcon
    case uploadIcon
    case uploadAltIcon
    case usdIcon
    case userIcon
    case userMdIcon
    case venusIcon
    case vimeoSquareIcon
    case vkIcon
    case volumeDownIcon
    case volumeOffIcon
    case volumeUpIcon
    case warningSignIcon
    case weiboIcon
    case windowsIcon
    case wrenchIcon
    case xingIcon
    case xingSignIcon
    case youtubeIcon
    case youtubePlayIcon
    case youtubeSignIcon
    case zoomInIcon
    case zoomOutIcon

    /** The icon font's total count of available icons. */
    public static var count: Int { return 694 }
}

extension FontAwesomeIcon : IconDrawable {
    /** The icon font's family name. */
    public static var familyName: String {
        return "FontAwesome"
    }
    /**
     Creates a new instance with the specified icon name.
     If there is no valid name is recognised, this initializer falls back to the first available icon.
     - parameter iconName: The icon name to use for the new instance.
     */
    public init(named iconName: String) {
        switch iconName.lowercased() {
        case "_279": self = ._279Icon
        case "_283": self = ._283Icon
        case "_303": self = ._303Icon
        case "_312": self = ._312Icon
        case "_317": self = ._317Icon
        case "_329": self = ._329Icon
        case "_334": self = ._334Icon
        case "_335": self = ._335Icon
        case "_366": self = ._366Icon
        case "_372": self = ._372Icon
        case "_374": self = ._374Icon
        case "_376": self = ._376Icon
        case "_378": self = ._378Icon
        case "_380": self = ._380Icon
        case "_382": self = ._382Icon
        case "_383": self = ._383Icon
        case "_384": self = ._384Icon
        case "_385": self = ._385Icon
        case "_386": self = ._386Icon
        case "_387": self = ._387Icon
        case "_388": self = ._388Icon
        case "_389": self = ._389Icon
        case "_392": self = ._392Icon
        case "_393": self = ._393Icon
        case "_395": self = ._395Icon
        case "_396": self = ._396Icon
        case "_397": self = ._397Icon
        case "_398": self = ._398Icon
        case "_399": self = ._399Icon
        case "_400": self = ._400Icon
        case "_402": self = ._402Icon
        case "_403": self = ._403Icon
        case "_404": self = ._404Icon
        case "_406": self = ._406Icon
        case "_407": self = ._407Icon
        case "_408": self = ._408Icon
        case "_409": self = ._409Icon
        case "_410": self = ._410Icon
        case "_411": self = ._411Icon
        case "_412": self = ._412Icon
        case "_413": self = ._413Icon
        case "_414": self = ._414Icon
        case "_415": self = ._415Icon
        case "_416": self = ._416Icon
        case "_417": self = ._417Icon
        case "_418": self = ._418Icon
        case "_419": self = ._419Icon
        case "_422": self = ._422Icon
        case "_423": self = ._423Icon
        case "_424": self = ._424Icon
        case "_425": self = ._425Icon
        case "_426": self = ._426Icon
        case "_427": self = ._427Icon
        case "_428": self = ._428Icon
        case "_429": self = ._429Icon
        case "_430": self = ._430Icon
        case "_431": self = ._431Icon
        case "_432": self = ._432Icon
        case "_433": self = ._433Icon
        case "_434": self = ._434Icon
        case "_438": self = ._438Icon
        case "_439": self = ._439Icon
        case "_443": self = ._443Icon
        case "_444": self = ._444Icon
        case "_445": self = ._445Icon
        case "_446": self = ._446Icon
        case "_447": self = ._447Icon
        case "_448": self = ._448Icon
        case "_449": self = ._449Icon
        case "_451": self = ._451Icon
        case "_452": self = ._452Icon
        case "_453": self = ._453Icon
        case "_454": self = ._454Icon
        case "_455": self = ._455Icon
        case "_456": self = ._456Icon
        case "_457": self = ._457Icon
        case "_458": self = ._458Icon
        case "_459": self = ._459Icon
        case "_460": self = ._460Icon
        case "_461": self = ._461Icon
        case "_462": self = ._462Icon
        case "_463": self = ._463Icon
        case "_464": self = ._464Icon
        case "_466": self = ._466Icon
        case "_467": self = ._467Icon
        case "_469": self = ._469Icon
        case "_470": self = ._470Icon
        case "_471": self = ._471Icon
        case "_472": self = ._472Icon
        case "_473": self = ._473Icon
        case "_474": self = ._474Icon
        case "_475": self = ._475Icon
        case "_476": self = ._476Icon
        case "_478": self = ._478Icon
        case "_479": self = ._479Icon
        case "_480": self = ._480Icon
        case "_481": self = ._481Icon
        case "_482": self = ._482Icon
        case "_483": self = ._483Icon
        case "_484": self = ._484Icon
        case "_485": self = ._485Icon
        case "_486": self = ._486Icon
        case "_487": self = ._487Icon
        case "_488": self = ._488Icon
        case "_489": self = ._489Icon
        case "_490": self = ._490Icon
        case "_491": self = ._491Icon
        case "_492": self = ._492Icon
        case "_493": self = ._493Icon
        case "_494": self = ._494Icon
        case "_496": self = ._496Icon
        case "_498": self = ._498Icon
        case "_499": self = ._499Icon
        case "_500": self = ._500Icon
        case "_501": self = ._501Icon
        case "_502": self = ._502Icon
        case "_503": self = ._503Icon
        case "_504": self = ._504Icon
        case "_505": self = ._505Icon
        case "_506": self = ._506Icon
        case "_507": self = ._507Icon
        case "_508": self = ._508Icon
        case "_509": self = ._509Icon
        case "_511": self = ._511Icon
        case "_512": self = ._512Icon
        case "_513": self = ._513Icon
        case "_514": self = ._514Icon
        case "_515": self = ._515Icon
        case "_516": self = ._516Icon
        case "_517": self = ._517Icon
        case "_518": self = ._518Icon
        case "_519": self = ._519Icon
        case "_520": self = ._520Icon
        case "_521": self = ._521Icon
        case "_522": self = ._522Icon
        case "_523": self = ._523Icon
        case "_524": self = ._524Icon
        case "_525": self = ._525Icon
        case "_526": self = ._526Icon
        case "_527": self = ._527Icon
        case "_528": self = ._528Icon
        case "_529": self = ._529Icon
        case "_530": self = ._530Icon
        case "_531": self = ._531Icon
        case "_532": self = ._532Icon
        case "_533": self = ._533Icon
        case "_534": self = ._534Icon
        case "_535": self = ._535Icon
        case "_536": self = ._536Icon
        case "_537": self = ._537Icon
        case "_538": self = ._538Icon
        case "_539": self = ._539Icon
        case "_540": self = ._540Icon
        case "_541": self = ._541Icon
        case "_542": self = ._542Icon
        case "_543": self = ._543Icon
        case "_544": self = ._544Icon
        case "_545": self = ._545Icon
        case "_546": self = ._546Icon
        case "_547": self = ._547Icon
        case "_548": self = ._548Icon
        case "_549": self = ._549Icon
        case "_550": self = ._550Icon
        case "_551": self = ._551Icon
        case "_552": self = ._552Icon
        case "_553": self = ._553Icon
        case "_554": self = ._554Icon
        case "_555": self = ._555Icon
        case "_556": self = ._556Icon
        case "_557": self = ._557Icon
        case "_558": self = ._558Icon
        case "_559": self = ._559Icon
        case "_560": self = ._560Icon
        case "_561": self = ._561Icon
        case "_562": self = ._562Icon
        case "_563": self = ._563Icon
        case "_564": self = ._564Icon
        case "_565": self = ._565Icon
        case "_566": self = ._566Icon
        case "_567": self = ._567Icon
        case "_568": self = ._568Icon
        case "_569": self = ._569Icon
        case "_572": self = ._572Icon
        case "_574": self = ._574Icon
        case "_575": self = ._575Icon
        case "_576": self = ._576Icon
        case "_577": self = ._577Icon
        case "_578": self = ._578Icon
        case "_579": self = ._579Icon
        case "_580": self = ._580Icon
        case "_581": self = ._581Icon
        case "_582": self = ._582Icon
        case "_583": self = ._583Icon
        case "_584": self = ._584Icon
        case "_585": self = ._585Icon
        case "_586": self = ._586Icon
        case "_587": self = ._587Icon
        case "_588": self = ._588Icon
        case "_589": self = ._589Icon
        case "_590": self = ._590Icon
        case "_591": self = ._591Icon
        case "_592": self = ._592Icon
        case "_593": self = ._593Icon
        case "_594": self = ._594Icon
        case "_595": self = ._595Icon
        case "_596": self = ._596Icon
        case "_597": self = ._597Icon
        case "_598": self = ._598Icon
        case "_602": self = ._602Icon
        case "_603": self = ._603Icon
        case "_604": self = ._604Icon
        case "_607": self = ._607Icon
        case "_608": self = ._608Icon
        case "_609": self = ._609Icon
        case "_610": self = ._610Icon
        case "_611": self = ._611Icon
        case "_612": self = ._612Icon
        case "_613": self = ._613Icon
        case "_614": self = ._614Icon
        case "_615": self = ._615Icon
        case "_616": self = ._616Icon
        case "_617": self = ._617Icon
        case "_618": self = ._618Icon
        case "_619": self = ._619Icon
        case "_620": self = ._620Icon
        case "_621": self = ._621Icon
        case "_622": self = ._622Icon
        case "_623": self = ._623Icon
        case "_624": self = ._624Icon
        case "_625": self = ._625Icon
        case "_626": self = ._626Icon
        case "_627": self = ._627Icon
        case "_628": self = ._628Icon
        case "_629": self = ._629Icon
        case "_698": self = ._698Icon
        case "adjust": self = .adjustIcon
        case "adn": self = .adnIcon
        case "align_center": self = .alignCenterIcon
        case "align_justify": self = .alignJustifyIcon
        case "align_left": self = .alignLeftIcon
        case "align_right": self = .alignRightIcon
        case "ambulance": self = .ambulanceIcon
        case "anchor": self = .anchorIcon
        case "android": self = .androidIcon
        case "angle_down": self = .angleDownIcon
        case "angle_left": self = .angleLeftIcon
        case "angle_right": self = .angleRightIcon
        case "angle_up": self = .angleUpIcon
        case "apple": self = .appleIcon
        case "archive": self = .archiveIcon
        case "arrow_circle_alt_left": self = .arrowCircleAltLeftIcon
        case "arrow_down": self = .arrowDownIcon
        case "arrow_left": self = .arrowLeftIcon
        case "arrow_right": self = .arrowRightIcon
        case "arrow_up": self = .arrowUpIcon
        case "asterisk": self = .asteriskIcon
        case "backward": self = .backwardIcon
        case "ban_circle": self = .banCircleIcon
        case "bar_chart": self = .barChartIcon
        case "barcode": self = .barcodeIcon
        case "beaker": self = .beakerIcon
        case "beer": self = .beerIcon
        case "bell": self = .bellIcon
        case "bell_alt": self = .bellAltIcon
        case "bitbucket_sign": self = .bitbucketSignIcon
        case "bold": self = .boldIcon
        case "bolt": self = .boltIcon
        case "book": self = .bookIcon
        case "bookmark": self = .bookmarkIcon
        case "bookmark_empty": self = .bookmarkEmptyIcon
        case "briefcase": self = .briefcaseIcon
        case "btc": self = .btcIcon
        case "bug": self = .bugIcon
        case "building": self = .buildingIcon
        case "bullhorn": self = .bullhornIcon
        case "bullseye": self = .bullseyeIcon
        case "calendar": self = .calendarIcon
        case "calendar_empty": self = .calendarEmptyIcon
        case "camera": self = .cameraIcon
        case "camera_retro": self = .cameraRetroIcon
        case "caret_down": self = .caretDownIcon
        case "caret_left": self = .caretLeftIcon
        case "caret_right": self = .caretRightIcon
        case "caret_up": self = .caretUpIcon
        case "certificate": self = .certificateIcon
        case "check": self = .checkIcon
        case "check_empty": self = .checkEmptyIcon
        case "check_minus": self = .checkMinusIcon
        case "check_sign": self = .checkSignIcon
        case "chevron_down": self = .chevronDownIcon
        case "chevron_left": self = .chevronLeftIcon
        case "chevron_right": self = .chevronRightIcon
        case "chevron_sign_down": self = .chevronSignDownIcon
        case "chevron_sign_left": self = .chevronSignLeftIcon
        case "chevron_sign_right": self = .chevronSignRightIcon
        case "chevron_sign_up": self = .chevronSignUpIcon
        case "chevron_up": self = .chevronUpIcon
        case "circle": self = .circleIcon
        case "circle_arrow_down": self = .circleArrowDownIcon
        case "circle_arrow_left": self = .circleArrowLeftIcon
        case "circle_arrow_right": self = .circleArrowRightIcon
        case "circle_arrow_up": self = .circleArrowUpIcon
        case "circle_blank": self = .circleBlankIcon
        case "cloud": self = .cloudIcon
        case "cloud_download": self = .cloudDownloadIcon
        case "cloud_upload": self = .cloudUploadIcon
        case "code": self = .codeIcon
        case "code_fork": self = .codeForkIcon
        case "coffee": self = .coffeeIcon
        case "cog": self = .cogIcon
        case "cogs": self = .cogsIcon
        case "collapse": self = .collapseIcon
        case "collapse_alt": self = .collapseAltIcon
        case "collapse_top": self = .collapseTopIcon
        case "columns": self = .columnsIcon
        case "comment": self = .commentIcon
        case "comment_alt": self = .commentAltIcon
        case "comments": self = .commentsIcon
        case "comments_alt": self = .commentsAltIcon
        case "compass": self = .compassIcon
        case "copy": self = .copyIcon
        case "credit_card": self = .creditCardIcon
        case "crop": self = .cropIcon
        case "css3": self = .css3Icon
        case "cut": self = .cutIcon
        case "dashboard": self = .dashboardIcon
        case "desktop": self = .desktopIcon
        case "dot_circle_alt": self = .dotCircleAltIcon
        case "double_angle_down": self = .doubleAngleDownIcon
        case "double_angle_left": self = .doubleAngleLeftIcon
        case "double_angle_right": self = .doubleAngleRightIcon
        case "double_angle_up": self = .doubleAngleUpIcon
        case "download": self = .downloadIcon
        case "download_alt": self = .downloadAltIcon
        case "dribble": self = .dribbleIcon
        case "dropbox": self = .dropboxIcon
        case "edit": self = .editIcon
        case "edit_sign": self = .editSignIcon
        case "eject": self = .ejectIcon
        case "ellipsis_horizontal": self = .ellipsisHorizontalIcon
        case "ellipsis_vertical": self = .ellipsisVerticalIcon
        case "envelope": self = .envelopeIcon
        case "envelope_alt": self = .envelopeAltIcon
        case "eur": self = .eurIcon
        case "exchange": self = .exchangeIcon
        case "exclamation": self = .exclamationIcon
        case "exclamation_sign": self = .exclamationSignIcon
        case "expand_alt": self = .expandAltIcon
        case "external_link": self = .externalLinkIcon
        case "eye_close": self = .eyeCloseIcon
        case "eye_open": self = .eyeOpenIcon
        case "f0fe": self = .f0feIcon
        case "f171": self = .f171Icon
        case "f1a1": self = .f1a1Icon
        case "f1a4": self = .f1a4Icon
        case "f1ab": self = .f1abIcon
        case "f1f3": self = .f1f3Icon
        case "f1fc": self = .f1fcIcon
        case "f210": self = .f210Icon
        case "f212": self = .f212Icon
        case "f260": self = .f260Icon
        case "f261": self = .f261Icon
        case "f263": self = .f263Icon
        case "f27e": self = .f27eIcon
        case "facebook": self = .facebookIcon
        case "facebook_sign": self = .facebookSignIcon
        case "facetime_video": self = .facetimeVideoIcon
        case "fast_backward": self = .fastBackwardIcon
        case "fast_forward": self = .fastForwardIcon
        case "female": self = .femaleIcon
        case "fighter_jet": self = .fighterJetIcon
        case "file": self = .fileIcon
        case "file_alt": self = .fileAltIcon
        case "file_text": self = .fileTextIcon
        case "file_text_alt": self = .fileTextAltIcon
        case "film": self = .filmIcon
        case "filter": self = .filterIcon
        case "fire": self = .fireIcon
        case "fire_extinguisher": self = .fireExtinguisherIcon
        case "flag": self = .flagIcon
        case "flag_alt": self = .flagAltIcon
        case "flag_checkered": self = .flagCheckeredIcon
        case "flickr": self = .flickrIcon
        case "folder_close": self = .folderCloseIcon
        case "folder_close_alt": self = .folderCloseAltIcon
        case "folder_open": self = .folderOpenIcon
        case "folder_open_alt": self = .folderOpenAltIcon
        case "font": self = .fontIcon
        case "food": self = .foodIcon
        case "forward": self = .forwardIcon
        case "foursquare": self = .foursquareIcon
        case "frown": self = .frownIcon
        case "fullscreen": self = .fullscreenIcon
        case "gamepad": self = .gamepadIcon
        case "gbp": self = .gbpIcon
        case "gift": self = .giftIcon
        case "github": self = .githubIcon
        case "github_alt": self = .githubAltIcon
        case "github_sign": self = .githubSignIcon
        case "gittip": self = .gittipIcon
        case "glass": self = .glassIcon
        case "globe": self = .globeIcon
        case "google_plus": self = .googlePlusIcon
        case "google_plus_sign": self = .googlePlusSignIcon
        case "group": self = .groupIcon
        case "h_sign": self = .hSignIcon
        case "hand_down": self = .handDownIcon
        case "hand_left": self = .handLeftIcon
        case "hand_right": self = .handRightIcon
        case "hand_up": self = .handUpIcon
        case "hdd": self = .hddIcon
        case "headphones": self = .headphonesIcon
        case "heart": self = .heartIcon
        case "heart_empty": self = .heartEmptyIcon
        case "home": self = .homeIcon
        case "hospital": self = .hospitalIcon
        case "html5": self = .html5Icon
        case "inbox": self = .inboxIcon
        case "indent_left": self = .indentLeftIcon
        case "indent_right": self = .indentRightIcon
        case "info_sign": self = .infoSignIcon
        case "inr": self = .inrIcon
        case "instagram": self = .instagramIcon
        case "italic": self = .italicIcon
        case "jpy": self = .jpyIcon
        case "key": self = .keyIcon
        case "keyboard": self = .keyboardIcon
        case "krw": self = .krwIcon
        case "laptop": self = .laptopIcon
        case "leaf": self = .leafIcon
        case "legal": self = .legalIcon
        case "lemon": self = .lemonIcon
        case "lessequal": self = .lessequalIcon
        case "level_down": self = .levelDownIcon
        case "level_up": self = .levelUpIcon
        case "light_bulb": self = .lightBulbIcon
        case "link": self = .linkIcon
        case "linkedin": self = .linkedinIcon
        case "linkedin_sign": self = .linkedinSignIcon
        case "linux": self = .linuxIcon
        case "list": self = .listIcon
        case "list_alt": self = .listAltIcon
        case "location_arrow": self = .locationArrowIcon
        case "lock": self = .lockIcon
        case "long_arrow_down": self = .longArrowDownIcon
        case "long_arrow_left": self = .longArrowLeftIcon
        case "long_arrow_right": self = .longArrowRightIcon
        case "long_arrow_up": self = .longArrowUpIcon
        case "magic": self = .magicIcon
        case "magnet": self = .magnetIcon
        case "male": self = .maleIcon
        case "map_marker": self = .mapMarkerIcon
        case "maxcdn": self = .maxcdnIcon
        case "medkit": self = .medkitIcon
        case "meh": self = .mehIcon
        case "microphone": self = .microphoneIcon
        case "microphone_off": self = .microphoneOffIcon
        case "minus": self = .minusIcon
        case "minus_sign": self = .minusSignIcon
        case "minus_sign_alt": self = .minusSignAltIcon
        case "mobile_phone": self = .mobilePhoneIcon
        case "money": self = .moneyIcon
        case "move": self = .moveIcon
        case "music": self = .musicIcon
        case "off": self = .offIcon
        case "ok": self = .okIcon
        case "ok_circle": self = .okCircleIcon
        case "ok_sign": self = .okSignIcon
        case "ol": self = .olIcon
        case "paper_clip": self = .paperClipIcon
        case "paste": self = .pasteIcon
        case "pause": self = .pauseIcon
        case "pencil": self = .pencilIcon
        case "phone": self = .phoneIcon
        case "phone_sign": self = .phoneSignIcon
        case "picture": self = .pictureIcon
        case "pinterest": self = .pinterestIcon
        case "pinterest_sign": self = .pinterestSignIcon
        case "plane": self = .planeIcon
        case "play": self = .playIcon
        case "play_circle": self = .playCircleIcon
        case "play_sign": self = .playSignIcon
        case "plus": self = .plusIcon
        case "plus_sign": self = .plusSignIcon
        case "plus_square_o": self = .plusSquareOIcon
        case "print": self = .printIcon
        case "pushpin": self = .pushpinIcon
        case "puzzle_piece": self = .puzzlePieceIcon
        case "qrcode": self = .qrcodeIcon
        case "question": self = .questionIcon
        case "question_sign": self = .questionSignIcon
        case "quote_left": self = .quoteLeftIcon
        case "quote_right": self = .quoteRightIcon
        case "random": self = .randomIcon
        case "refresh": self = .refreshIcon
        case "remove": self = .removeIcon
        case "remove_circle": self = .removeCircleIcon
        case "remove_sign": self = .removeSignIcon
        case "renren": self = .renrenIcon
        case "reorder": self = .reorderIcon
        case "repeat": self = .repeatIcon
        case "reply": self = .replyIcon
        case "reply_all": self = .replyAllIcon
        case "resize_full": self = .resizeFullIcon
        case "resize_horizontal": self = .resizeHorizontalIcon
        case "resize_small": self = .resizeSmallIcon
        case "resize_vertical": self = .resizeVerticalIcon
        case "retweet": self = .retweetIcon
        case "road": self = .roadIcon
        case "rocket": self = .rocketIcon
        case "rss": self = .rssIcon
        case "rub": self = .rubIcon
        case "save": self = .saveIcon
        case "screenshot": self = .screenshotIcon
        case "search": self = .searchIcon
        case "share": self = .shareIcon
        case "share_alt": self = .shareAltIcon
        case "share_sign": self = .shareSignIcon
        case "shield": self = .shieldIcon
        case "shopping_cart": self = .shoppingCartIcon
        case "sign_blank": self = .signBlankIcon
        case "signal": self = .signalIcon
        case "signin": self = .signinIcon
        case "signout": self = .signoutIcon
        case "sitemap": self = .sitemapIcon
        case "skype": self = .skypeIcon
        case "smile": self = .smileIcon
        case "sort": self = .sortIcon
        case "sort_by_alphabet": self = .sortByAlphabetIcon
        case "sort_by_attributes": self = .sortByAttributesIcon
        case "sort_by_attributes_alt": self = .sortByAttributesAltIcon
        case "sort_by_order": self = .sortByOrderIcon
        case "sort_by_order_alt": self = .sortByOrderAltIcon
        case "sort_down": self = .sortDownIcon
        case "sort_up": self = .sortUpIcon
        case "spinner": self = .spinnerIcon
        case "stack_exchange": self = .stackExchangeIcon
        case "stackexchange": self = .stackexchangeIcon
        case "star": self = .starIcon
        case "star_empty": self = .starEmptyIcon
        case "star_half": self = .starHalfIcon
        case "star_half_empty": self = .starHalfEmptyIcon
        case "step_backward": self = .stepBackwardIcon
        case "step_forward": self = .stepForwardIcon
        case "stethoscope": self = .stethoscopeIcon
        case "stop": self = .stopIcon
        case "strikethrough": self = .strikethroughIcon
        case "subscript": self = .subscriptIcon
        case "suitcase": self = .suitcaseIcon
        case "sun": self = .sunIcon
        case "superscript": self = .superscriptIcon
        case "table": self = .tableIcon
        case "tablet": self = .tabletIcon
        case "tag": self = .tagIcon
        case "tags": self = .tagsIcon
        case "tasks": self = .tasksIcon
        case "terminal": self = .terminalIcon
        case "text_height": self = .textHeightIcon
        case "text_width": self = .textWidthIcon
        case "th": self = .thIcon
        case "th_large": self = .thLargeIcon
        case "th_list": self = .thListIcon
        case "thumbs_down_alt": self = .thumbsDownAltIcon
        case "thumbs_up_alt": self = .thumbsUpAltIcon
        case "ticket": self = .ticketIcon
        case "time": self = .timeIcon
        case "tint": self = .tintIcon
        case "trash": self = .trashIcon
        case "trello": self = .trelloIcon
        case "trophy": self = .trophyIcon
        case "truck": self = .truckIcon
        case "tumblr": self = .tumblrIcon
        case "tumblr_sign": self = .tumblrSignIcon
        case "twitter": self = .twitterIcon
        case "twitter_sign": self = .twitterSignIcon
        case "ul": self = .ulIcon
        case "umbrella": self = .umbrellaIcon
        case "underline": self = .underlineIcon
        case "undo": self = .undoIcon
        case "unif1a0": self = .uniF1A0Icon
        case "unif1b1": self = .uniF1B1Icon
        case "unif1c0": self = .uniF1C0Icon
        case "unif1c1": self = .uniF1C1Icon
        case "unif1d0": self = .uniF1D0Icon
        case "unif1d1": self = .uniF1D1Icon
        case "unif1d2": self = .uniF1D2Icon
        case "unif1d5": self = .uniF1D5Icon
        case "unif1d6": self = .uniF1D6Icon
        case "unif1d7": self = .uniF1D7Icon
        case "unif1e0": self = .uniF1E0Icon
        case "unif1f0": self = .uniF1F0Icon
        case "unif280": self = .uniF280Icon
        case "unif281": self = .uniF281Icon
        case "unif285": self = .uniF285Icon
        case "unif286": self = .uniF286Icon
        case "unif2a0": self = .uniF2A0Icon
        case "unif2a1": self = .uniF2A1Icon
        case "unif2a2": self = .uniF2A2Icon
        case "unif2a3": self = .uniF2A3Icon
        case "unif2a4": self = .uniF2A4Icon
        case "unif2a5": self = .uniF2A5Icon
        case "unif2a6": self = .uniF2A6Icon
        case "unif2a7": self = .uniF2A7Icon
        case "unif2a8": self = .uniF2A8Icon
        case "unif2a9": self = .uniF2A9Icon
        case "unif2aa": self = .uniF2AAIcon
        case "unif2ab": self = .uniF2ABIcon
        case "unif2ac": self = .uniF2ACIcon
        case "unif2ad": self = .uniF2ADIcon
        case "unif2ae": self = .uniF2AEIcon
        case "unif2b0": self = .uniF2B0Icon
        case "unif2b1": self = .uniF2B1Icon
        case "unif2b2": self = .uniF2B2Icon
        case "unif2b3": self = .uniF2B3Icon
        case "unif2b4": self = .uniF2B4Icon
        case "unif2b5": self = .uniF2B5Icon
        case "unif2b6": self = .uniF2B6Icon
        case "unif2b7": self = .uniF2B7Icon
        case "unif2b8": self = .uniF2B8Icon
        case "unif2b9": self = .uniF2B9Icon
        case "unif2ba": self = .uniF2BAIcon
        case "unif2bb": self = .uniF2BBIcon
        case "unif2bc": self = .uniF2BCIcon
        case "unif2bd": self = .uniF2BDIcon
        case "unif2be": self = .uniF2BEIcon
        case "unif2c0": self = .uniF2C0Icon
        case "unif2c1": self = .uniF2C1Icon
        case "unif2c2": self = .uniF2C2Icon
        case "unif2c3": self = .uniF2C3Icon
        case "unif2c4": self = .uniF2C4Icon
        case "unif2c5": self = .uniF2C5Icon
        case "unif2c6": self = .uniF2C6Icon
        case "unif2c7": self = .uniF2C7Icon
        case "unif2c8": self = .uniF2C8Icon
        case "unif2c9": self = .uniF2C9Icon
        case "unif2ca": self = .uniF2CAIcon
        case "unif2cb": self = .uniF2CBIcon
        case "unif2cc": self = .uniF2CCIcon
        case "unif2cd": self = .uniF2CDIcon
        case "unif2ce": self = .uniF2CEIcon
        case "unif2d0": self = .uniF2D0Icon
        case "unif2d1": self = .uniF2D1Icon
        case "unif2d2": self = .uniF2D2Icon
        case "unif2d3": self = .uniF2D3Icon
        case "unif2d4": self = .uniF2D4Icon
        case "unif2d5": self = .uniF2D5Icon
        case "unif2d6": self = .uniF2D6Icon
        case "unif2d7": self = .uniF2D7Icon
        case "unif2d8": self = .uniF2D8Icon
        case "unif2d9": self = .uniF2D9Icon
        case "unif2da": self = .uniF2DAIcon
        case "unif2db": self = .uniF2DBIcon
        case "unif2dc": self = .uniF2DCIcon
        case "unif2dd": self = .uniF2DDIcon
        case "unif2de": self = .uniF2DEIcon
        case "unif2e0": self = .uniF2E0Icon
        case "unif2e1": self = .uniF2E1Icon
        case "unif2e2": self = .uniF2E2Icon
        case "unif2e3": self = .uniF2E3Icon
        case "unif2e4": self = .uniF2E4Icon
        case "unif2e5": self = .uniF2E5Icon
        case "unif2e6": self = .uniF2E6Icon
        case "unif2e7": self = .uniF2E7Icon
        case "unif2e9": self = .uniF2E9Icon
        case "unif2ea": self = .uniF2EAIcon
        case "unif2eb": self = .uniF2EBIcon
        case "unif2ec": self = .uniF2ECIcon
        case "unif2ed": self = .uniF2EDIcon
        case "unif2ee": self = .uniF2EEIcon
        case "unlink": self = .unlinkIcon
        case "unlock": self = .unlockIcon
        case "unlock_alt": self = .unlockAltIcon
        case "upload": self = .uploadIcon
        case "upload_alt": self = .uploadAltIcon
        case "usd": self = .usdIcon
        case "user": self = .userIcon
        case "user_md": self = .userMdIcon
        case "venus": self = .venusIcon
        case "vimeo_square": self = .vimeoSquareIcon
        case "vk": self = .vkIcon
        case "volume_down": self = .volumeDownIcon
        case "volume_off": self = .volumeOffIcon
        case "volume_up": self = .volumeUpIcon
        case "warning_sign": self = .warningSignIcon
        case "weibo": self = .weiboIcon
        case "windows": self = .windowsIcon
        case "wrench": self = .wrenchIcon
        case "xing": self = .xingIcon
        case "xing_sign": self = .xingSignIcon
        case "youtube": self = .youtubeIcon
        case "youtube_play": self = .youtubePlayIcon
        case "youtube_sign": self = .youtubeSignIcon
        case "zoom_in": self = .zoomInIcon
        case "zoom_out": self = .zoomOutIcon
        default: self = FontAwesomeIcon(rawValue: 0)!
        }
    }
    /** The icon's name. */
    public var name: String {
        switch self {
        case ._279Icon: return "_279"
        case ._283Icon: return "_283"
        case ._303Icon: return "_303"
        case ._312Icon: return "_312"
        case ._317Icon: return "_317"
        case ._329Icon: return "_329"
        case ._334Icon: return "_334"
        case ._335Icon: return "_335"
        case ._366Icon: return "_366"
        case ._372Icon: return "_372"
        case ._374Icon: return "_374"
        case ._376Icon: return "_376"
        case ._378Icon: return "_378"
        case ._380Icon: return "_380"
        case ._382Icon: return "_382"
        case ._383Icon: return "_383"
        case ._384Icon: return "_384"
        case ._385Icon: return "_385"
        case ._386Icon: return "_386"
        case ._387Icon: return "_387"
        case ._388Icon: return "_388"
        case ._389Icon: return "_389"
        case ._392Icon: return "_392"
        case ._393Icon: return "_393"
        case ._395Icon: return "_395"
        case ._396Icon: return "_396"
        case ._397Icon: return "_397"
        case ._398Icon: return "_398"
        case ._399Icon: return "_399"
        case ._400Icon: return "_400"
        case ._402Icon: return "_402"
        case ._403Icon: return "_403"
        case ._404Icon: return "_404"
        case ._406Icon: return "_406"
        case ._407Icon: return "_407"
        case ._408Icon: return "_408"
        case ._409Icon: return "_409"
        case ._410Icon: return "_410"
        case ._411Icon: return "_411"
        case ._412Icon: return "_412"
        case ._413Icon: return "_413"
        case ._414Icon: return "_414"
        case ._415Icon: return "_415"
        case ._416Icon: return "_416"
        case ._417Icon: return "_417"
        case ._418Icon: return "_418"
        case ._419Icon: return "_419"
        case ._422Icon: return "_422"
        case ._423Icon: return "_423"
        case ._424Icon: return "_424"
        case ._425Icon: return "_425"
        case ._426Icon: return "_426"
        case ._427Icon: return "_427"
        case ._428Icon: return "_428"
        case ._429Icon: return "_429"
        case ._430Icon: return "_430"
        case ._431Icon: return "_431"
        case ._432Icon: return "_432"
        case ._433Icon: return "_433"
        case ._434Icon: return "_434"
        case ._438Icon: return "_438"
        case ._439Icon: return "_439"
        case ._443Icon: return "_443"
        case ._444Icon: return "_444"
        case ._445Icon: return "_445"
        case ._446Icon: return "_446"
        case ._447Icon: return "_447"
        case ._448Icon: return "_448"
        case ._449Icon: return "_449"
        case ._451Icon: return "_451"
        case ._452Icon: return "_452"
        case ._453Icon: return "_453"
        case ._454Icon: return "_454"
        case ._455Icon: return "_455"
        case ._456Icon: return "_456"
        case ._457Icon: return "_457"
        case ._458Icon: return "_458"
        case ._459Icon: return "_459"
        case ._460Icon: return "_460"
        case ._461Icon: return "_461"
        case ._462Icon: return "_462"
        case ._463Icon: return "_463"
        case ._464Icon: return "_464"
        case ._466Icon: return "_466"
        case ._467Icon: return "_467"
        case ._469Icon: return "_469"
        case ._470Icon: return "_470"
        case ._471Icon: return "_471"
        case ._472Icon: return "_472"
        case ._473Icon: return "_473"
        case ._474Icon: return "_474"
        case ._475Icon: return "_475"
        case ._476Icon: return "_476"
        case ._478Icon: return "_478"
        case ._479Icon: return "_479"
        case ._480Icon: return "_480"
        case ._481Icon: return "_481"
        case ._482Icon: return "_482"
        case ._483Icon: return "_483"
        case ._484Icon: return "_484"
        case ._485Icon: return "_485"
        case ._486Icon: return "_486"
        case ._487Icon: return "_487"
        case ._488Icon: return "_488"
        case ._489Icon: return "_489"
        case ._490Icon: return "_490"
        case ._491Icon: return "_491"
        case ._492Icon: return "_492"
        case ._493Icon: return "_493"
        case ._494Icon: return "_494"
        case ._496Icon: return "_496"
        case ._498Icon: return "_498"
        case ._499Icon: return "_499"
        case ._500Icon: return "_500"
        case ._501Icon: return "_501"
        case ._502Icon: return "_502"
        case ._503Icon: return "_503"
        case ._504Icon: return "_504"
        case ._505Icon: return "_505"
        case ._506Icon: return "_506"
        case ._507Icon: return "_507"
        case ._508Icon: return "_508"
        case ._509Icon: return "_509"
        case ._511Icon: return "_511"
        case ._512Icon: return "_512"
        case ._513Icon: return "_513"
        case ._514Icon: return "_514"
        case ._515Icon: return "_515"
        case ._516Icon: return "_516"
        case ._517Icon: return "_517"
        case ._518Icon: return "_518"
        case ._519Icon: return "_519"
        case ._520Icon: return "_520"
        case ._521Icon: return "_521"
        case ._522Icon: return "_522"
        case ._523Icon: return "_523"
        case ._524Icon: return "_524"
        case ._525Icon: return "_525"
        case ._526Icon: return "_526"
        case ._527Icon: return "_527"
        case ._528Icon: return "_528"
        case ._529Icon: return "_529"
        case ._530Icon: return "_530"
        case ._531Icon: return "_531"
        case ._532Icon: return "_532"
        case ._533Icon: return "_533"
        case ._534Icon: return "_534"
        case ._535Icon: return "_535"
        case ._536Icon: return "_536"
        case ._537Icon: return "_537"
        case ._538Icon: return "_538"
        case ._539Icon: return "_539"
        case ._540Icon: return "_540"
        case ._541Icon: return "_541"
        case ._542Icon: return "_542"
        case ._543Icon: return "_543"
        case ._544Icon: return "_544"
        case ._545Icon: return "_545"
        case ._546Icon: return "_546"
        case ._547Icon: return "_547"
        case ._548Icon: return "_548"
        case ._549Icon: return "_549"
        case ._550Icon: return "_550"
        case ._551Icon: return "_551"
        case ._552Icon: return "_552"
        case ._553Icon: return "_553"
        case ._554Icon: return "_554"
        case ._555Icon: return "_555"
        case ._556Icon: return "_556"
        case ._557Icon: return "_557"
        case ._558Icon: return "_558"
        case ._559Icon: return "_559"
        case ._560Icon: return "_560"
        case ._561Icon: return "_561"
        case ._562Icon: return "_562"
        case ._563Icon: return "_563"
        case ._564Icon: return "_564"
        case ._565Icon: return "_565"
        case ._566Icon: return "_566"
        case ._567Icon: return "_567"
        case ._568Icon: return "_568"
        case ._569Icon: return "_569"
        case ._572Icon: return "_572"
        case ._574Icon: return "_574"
        case ._575Icon: return "_575"
        case ._576Icon: return "_576"
        case ._577Icon: return "_577"
        case ._578Icon: return "_578"
        case ._579Icon: return "_579"
        case ._580Icon: return "_580"
        case ._581Icon: return "_581"
        case ._582Icon: return "_582"
        case ._583Icon: return "_583"
        case ._584Icon: return "_584"
        case ._585Icon: return "_585"
        case ._586Icon: return "_586"
        case ._587Icon: return "_587"
        case ._588Icon: return "_588"
        case ._589Icon: return "_589"
        case ._590Icon: return "_590"
        case ._591Icon: return "_591"
        case ._592Icon: return "_592"
        case ._593Icon: return "_593"
        case ._594Icon: return "_594"
        case ._595Icon: return "_595"
        case ._596Icon: return "_596"
        case ._597Icon: return "_597"
        case ._598Icon: return "_598"
        case ._602Icon: return "_602"
        case ._603Icon: return "_603"
        case ._604Icon: return "_604"
        case ._607Icon: return "_607"
        case ._608Icon: return "_608"
        case ._609Icon: return "_609"
        case ._610Icon: return "_610"
        case ._611Icon: return "_611"
        case ._612Icon: return "_612"
        case ._613Icon: return "_613"
        case ._614Icon: return "_614"
        case ._615Icon: return "_615"
        case ._616Icon: return "_616"
        case ._617Icon: return "_617"
        case ._618Icon: return "_618"
        case ._619Icon: return "_619"
        case ._620Icon: return "_620"
        case ._621Icon: return "_621"
        case ._622Icon: return "_622"
        case ._623Icon: return "_623"
        case ._624Icon: return "_624"
        case ._625Icon: return "_625"
        case ._626Icon: return "_626"
        case ._627Icon: return "_627"
        case ._628Icon: return "_628"
        case ._629Icon: return "_629"
        case ._698Icon: return "_698"
        case .adjustIcon: return "adjust"
        case .adnIcon: return "adn"
        case .alignCenterIcon: return "align_center"
        case .alignJustifyIcon: return "align_justify"
        case .alignLeftIcon: return "align_left"
        case .alignRightIcon: return "align_right"
        case .ambulanceIcon: return "ambulance"
        case .anchorIcon: return "anchor"
        case .androidIcon: return "android"
        case .angleDownIcon: return "angle_down"
        case .angleLeftIcon: return "angle_left"
        case .angleRightIcon: return "angle_right"
        case .angleUpIcon: return "angle_up"
        case .appleIcon: return "apple"
        case .archiveIcon: return "archive"
        case .arrowCircleAltLeftIcon: return "arrow_circle_alt_left"
        case .arrowDownIcon: return "arrow_down"
        case .arrowLeftIcon: return "arrow_left"
        case .arrowRightIcon: return "arrow_right"
        case .arrowUpIcon: return "arrow_up"
        case .asteriskIcon: return "asterisk"
        case .backwardIcon: return "backward"
        case .banCircleIcon: return "ban_circle"
        case .barChartIcon: return "bar_chart"
        case .barcodeIcon: return "barcode"
        case .beakerIcon: return "beaker"
        case .beerIcon: return "beer"
        case .bellIcon: return "bell"
        case .bellAltIcon: return "bell_alt"
        case .bitbucketSignIcon: return "bitbucket_sign"
        case .boldIcon: return "bold"
        case .boltIcon: return "bolt"
        case .bookIcon: return "book"
        case .bookmarkIcon: return "bookmark"
        case .bookmarkEmptyIcon: return "bookmark_empty"
        case .briefcaseIcon: return "briefcase"
        case .btcIcon: return "btc"
        case .bugIcon: return "bug"
        case .buildingIcon: return "building"
        case .bullhornIcon: return "bullhorn"
        case .bullseyeIcon: return "bullseye"
        case .calendarIcon: return "calendar"
        case .calendarEmptyIcon: return "calendar_empty"
        case .cameraIcon: return "camera"
        case .cameraRetroIcon: return "camera_retro"
        case .caretDownIcon: return "caret_down"
        case .caretLeftIcon: return "caret_left"
        case .caretRightIcon: return "caret_right"
        case .caretUpIcon: return "caret_up"
        case .certificateIcon: return "certificate"
        case .checkIcon: return "check"
        case .checkEmptyIcon: return "check_empty"
        case .checkMinusIcon: return "check_minus"
        case .checkSignIcon: return "check_sign"
        case .chevronDownIcon: return "chevron_down"
        case .chevronLeftIcon: return "chevron_left"
        case .chevronRightIcon: return "chevron_right"
        case .chevronSignDownIcon: return "chevron_sign_down"
        case .chevronSignLeftIcon: return "chevron_sign_left"
        case .chevronSignRightIcon: return "chevron_sign_right"
        case .chevronSignUpIcon: return "chevron_sign_up"
        case .chevronUpIcon: return "chevron_up"
        case .circleIcon: return "circle"
        case .circleArrowDownIcon: return "circle_arrow_down"
        case .circleArrowLeftIcon: return "circle_arrow_left"
        case .circleArrowRightIcon: return "circle_arrow_right"
        case .circleArrowUpIcon: return "circle_arrow_up"
        case .circleBlankIcon: return "circle_blank"
        case .cloudIcon: return "cloud"
        case .cloudDownloadIcon: return "cloud_download"
        case .cloudUploadIcon: return "cloud_upload"
        case .codeIcon: return "code"
        case .codeForkIcon: return "code_fork"
        case .coffeeIcon: return "coffee"
        case .cogIcon: return "cog"
        case .cogsIcon: return "cogs"
        case .collapseIcon: return "collapse"
        case .collapseAltIcon: return "collapse_alt"
        case .collapseTopIcon: return "collapse_top"
        case .columnsIcon: return "columns"
        case .commentIcon: return "comment"
        case .commentAltIcon: return "comment_alt"
        case .commentsIcon: return "comments"
        case .commentsAltIcon: return "comments_alt"
        case .compassIcon: return "compass"
        case .copyIcon: return "copy"
        case .creditCardIcon: return "credit_card"
        case .cropIcon: return "crop"
        case .css3Icon: return "css3"
        case .cutIcon: return "cut"
        case .dashboardIcon: return "dashboard"
        case .desktopIcon: return "desktop"
        case .dotCircleAltIcon: return "dot_circle_alt"
        case .doubleAngleDownIcon: return "double_angle_down"
        case .doubleAngleLeftIcon: return "double_angle_left"
        case .doubleAngleRightIcon: return "double_angle_right"
        case .doubleAngleUpIcon: return "double_angle_up"
        case .downloadIcon: return "download"
        case .downloadAltIcon: return "download_alt"
        case .dribbleIcon: return "dribble"
        case .dropboxIcon: return "dropbox"
        case .editIcon: return "edit"
        case .editSignIcon: return "edit_sign"
        case .ejectIcon: return "eject"
        case .ellipsisHorizontalIcon: return "ellipsis_horizontal"
        case .ellipsisVerticalIcon: return "ellipsis_vertical"
        case .envelopeIcon: return "envelope"
        case .envelopeAltIcon: return "envelope_alt"
        case .eurIcon: return "eur"
        case .exchangeIcon: return "exchange"
        case .exclamationIcon: return "exclamation"
        case .exclamationSignIcon: return "exclamation_sign"
        case .expandAltIcon: return "expand_alt"
        case .externalLinkIcon: return "external_link"
        case .eyeCloseIcon: return "eye_close"
        case .eyeOpenIcon: return "eye_open"
        case .f0feIcon: return "f0fe"
        case .f171Icon: return "f171"
        case .f1a1Icon: return "f1a1"
        case .f1a4Icon: return "f1a4"
        case .f1abIcon: return "f1ab"
        case .f1f3Icon: return "f1f3"
        case .f1fcIcon: return "f1fc"
        case .f210Icon: return "f210"
        case .f212Icon: return "f212"
        case .f260Icon: return "f260"
        case .f261Icon: return "f261"
        case .f263Icon: return "f263"
        case .f27eIcon: return "f27e"
        case .facebookIcon: return "facebook"
        case .facebookSignIcon: return "facebook_sign"
        case .facetimeVideoIcon: return "facetime_video"
        case .fastBackwardIcon: return "fast_backward"
        case .fastForwardIcon: return "fast_forward"
        case .femaleIcon: return "female"
        case .fighterJetIcon: return "fighter_jet"
        case .fileIcon: return "file"
        case .fileAltIcon: return "file_alt"
        case .fileTextIcon: return "file_text"
        case .fileTextAltIcon: return "file_text_alt"
        case .filmIcon: return "film"
        case .filterIcon: return "filter"
        case .fireIcon: return "fire"
        case .fireExtinguisherIcon: return "fire_extinguisher"
        case .flagIcon: return "flag"
        case .flagAltIcon: return "flag_alt"
        case .flagCheckeredIcon: return "flag_checkered"
        case .flickrIcon: return "flickr"
        case .folderCloseIcon: return "folder_close"
        case .folderCloseAltIcon: return "folder_close_alt"
        case .folderOpenIcon: return "folder_open"
        case .folderOpenAltIcon: return "folder_open_alt"
        case .fontIcon: return "font"
        case .foodIcon: return "food"
        case .forwardIcon: return "forward"
        case .foursquareIcon: return "foursquare"
        case .frownIcon: return "frown"
        case .fullscreenIcon: return "fullscreen"
        case .gamepadIcon: return "gamepad"
        case .gbpIcon: return "gbp"
        case .giftIcon: return "gift"
        case .githubIcon: return "github"
        case .githubAltIcon: return "github_alt"
        case .githubSignIcon: return "github_sign"
        case .gittipIcon: return "gittip"
        case .glassIcon: return "glass"
        case .globeIcon: return "globe"
        case .googlePlusIcon: return "google_plus"
        case .googlePlusSignIcon: return "google_plus_sign"
        case .groupIcon: return "group"
        case .hSignIcon: return "h_sign"
        case .handDownIcon: return "hand_down"
        case .handLeftIcon: return "hand_left"
        case .handRightIcon: return "hand_right"
        case .handUpIcon: return "hand_up"
        case .hddIcon: return "hdd"
        case .headphonesIcon: return "headphones"
        case .heartIcon: return "heart"
        case .heartEmptyIcon: return "heart_empty"
        case .homeIcon: return "home"
        case .hospitalIcon: return "hospital"
        case .html5Icon: return "html5"
        case .inboxIcon: return "inbox"
        case .indentLeftIcon: return "indent_left"
        case .indentRightIcon: return "indent_right"
        case .infoSignIcon: return "info_sign"
        case .inrIcon: return "inr"
        case .instagramIcon: return "instagram"
        case .italicIcon: return "italic"
        case .jpyIcon: return "jpy"
        case .keyIcon: return "key"
        case .keyboardIcon: return "keyboard"
        case .krwIcon: return "krw"
        case .laptopIcon: return "laptop"
        case .leafIcon: return "leaf"
        case .legalIcon: return "legal"
        case .lemonIcon: return "lemon"
        case .lessequalIcon: return "lessequal"
        case .levelDownIcon: return "level_down"
        case .levelUpIcon: return "level_up"
        case .lightBulbIcon: return "light_bulb"
        case .linkIcon: return "link"
        case .linkedinIcon: return "linkedin"
        case .linkedinSignIcon: return "linkedin_sign"
        case .linuxIcon: return "linux"
        case .listIcon: return "list"
        case .listAltIcon: return "list_alt"
        case .locationArrowIcon: return "location_arrow"
        case .lockIcon: return "lock"
        case .longArrowDownIcon: return "long_arrow_down"
        case .longArrowLeftIcon: return "long_arrow_left"
        case .longArrowRightIcon: return "long_arrow_right"
        case .longArrowUpIcon: return "long_arrow_up"
        case .magicIcon: return "magic"
        case .magnetIcon: return "magnet"
        case .maleIcon: return "male"
        case .mapMarkerIcon: return "map_marker"
        case .maxcdnIcon: return "maxcdn"
        case .medkitIcon: return "medkit"
        case .mehIcon: return "meh"
        case .microphoneIcon: return "microphone"
        case .microphoneOffIcon: return "microphone_off"
        case .minusIcon: return "minus"
        case .minusSignIcon: return "minus_sign"
        case .minusSignAltIcon: return "minus_sign_alt"
        case .mobilePhoneIcon: return "mobile_phone"
        case .moneyIcon: return "money"
        case .moveIcon: return "move"
        case .musicIcon: return "music"
        case .offIcon: return "off"
        case .okIcon: return "ok"
        case .okCircleIcon: return "ok_circle"
        case .okSignIcon: return "ok_sign"
        case .olIcon: return "ol"
        case .paperClipIcon: return "paper_clip"
        case .pasteIcon: return "paste"
        case .pauseIcon: return "pause"
        case .pencilIcon: return "pencil"
        case .phoneIcon: return "phone"
        case .phoneSignIcon: return "phone_sign"
        case .pictureIcon: return "picture"
        case .pinterestIcon: return "pinterest"
        case .pinterestSignIcon: return "pinterest_sign"
        case .planeIcon: return "plane"
        case .playIcon: return "play"
        case .playCircleIcon: return "play_circle"
        case .playSignIcon: return "play_sign"
        case .plusIcon: return "plus"
        case .plusSignIcon: return "plus_sign"
        case .plusSquareOIcon: return "plus_square_o"
        case .printIcon: return "print"
        case .pushpinIcon: return "pushpin"
        case .puzzlePieceIcon: return "puzzle_piece"
        case .qrcodeIcon: return "qrcode"
        case .questionIcon: return "question"
        case .questionSignIcon: return "question_sign"
        case .quoteLeftIcon: return "quote_left"
        case .quoteRightIcon: return "quote_right"
        case .randomIcon: return "random"
        case .refreshIcon: return "refresh"
        case .removeIcon: return "remove"
        case .removeCircleIcon: return "remove_circle"
        case .removeSignIcon: return "remove_sign"
        case .renrenIcon: return "renren"
        case .reorderIcon: return "reorder"
        case .repeatIcon: return "repeat"
        case .replyIcon: return "reply"
        case .replyAllIcon: return "reply_all"
        case .resizeFullIcon: return "resize_full"
        case .resizeHorizontalIcon: return "resize_horizontal"
        case .resizeSmallIcon: return "resize_small"
        case .resizeVerticalIcon: return "resize_vertical"
        case .retweetIcon: return "retweet"
        case .roadIcon: return "road"
        case .rocketIcon: return "rocket"
        case .rssIcon: return "rss"
        case .rubIcon: return "rub"
        case .saveIcon: return "save"
        case .screenshotIcon: return "screenshot"
        case .searchIcon: return "search"
        case .shareIcon: return "share"
        case .shareAltIcon: return "share_alt"
        case .shareSignIcon: return "share_sign"
        case .shieldIcon: return "shield"
        case .shoppingCartIcon: return "shopping_cart"
        case .signBlankIcon: return "sign_blank"
        case .signalIcon: return "signal"
        case .signinIcon: return "signin"
        case .signoutIcon: return "signout"
        case .sitemapIcon: return "sitemap"
        case .skypeIcon: return "skype"
        case .smileIcon: return "smile"
        case .sortIcon: return "sort"
        case .sortByAlphabetIcon: return "sort_by_alphabet"
        case .sortByAttributesIcon: return "sort_by_attributes"
        case .sortByAttributesAltIcon: return "sort_by_attributes_alt"
        case .sortByOrderIcon: return "sort_by_order"
        case .sortByOrderAltIcon: return "sort_by_order_alt"
        case .sortDownIcon: return "sort_down"
        case .sortUpIcon: return "sort_up"
        case .spinnerIcon: return "spinner"
        case .stackExchangeIcon: return "stack_exchange"
        case .stackexchangeIcon: return "stackexchange"
        case .starIcon: return "star"
        case .starEmptyIcon: return "star_empty"
        case .starHalfIcon: return "star_half"
        case .starHalfEmptyIcon: return "star_half_empty"
        case .stepBackwardIcon: return "step_backward"
        case .stepForwardIcon: return "step_forward"
        case .stethoscopeIcon: return "stethoscope"
        case .stopIcon: return "stop"
        case .strikethroughIcon: return "strikethrough"
        case .subscriptIcon: return "subscript"
        case .suitcaseIcon: return "suitcase"
        case .sunIcon: return "sun"
        case .superscriptIcon: return "superscript"
        case .tableIcon: return "table"
        case .tabletIcon: return "tablet"
        case .tagIcon: return "tag"
        case .tagsIcon: return "tags"
        case .tasksIcon: return "tasks"
        case .terminalIcon: return "terminal"
        case .textHeightIcon: return "text_height"
        case .textWidthIcon: return "text_width"
        case .thIcon: return "th"
        case .thLargeIcon: return "th_large"
        case .thListIcon: return "th_list"
        case .thumbsDownAltIcon: return "thumbs_down_alt"
        case .thumbsUpAltIcon: return "thumbs_up_alt"
        case .ticketIcon: return "ticket"
        case .timeIcon: return "time"
        case .tintIcon: return "tint"
        case .trashIcon: return "trash"
        case .trelloIcon: return "trello"
        case .trophyIcon: return "trophy"
        case .truckIcon: return "truck"
        case .tumblrIcon: return "tumblr"
        case .tumblrSignIcon: return "tumblr_sign"
        case .twitterIcon: return "twitter"
        case .twitterSignIcon: return "twitter_sign"
        case .ulIcon: return "ul"
        case .umbrellaIcon: return "umbrella"
        case .underlineIcon: return "underline"
        case .undoIcon: return "undo"
        case .uniF1A0Icon: return "unif1a0"
        case .uniF1B1Icon: return "unif1b1"
        case .uniF1C0Icon: return "unif1c0"
        case .uniF1C1Icon: return "unif1c1"
        case .uniF1D0Icon: return "unif1d0"
        case .uniF1D1Icon: return "unif1d1"
        case .uniF1D2Icon: return "unif1d2"
        case .uniF1D5Icon: return "unif1d5"
        case .uniF1D6Icon: return "unif1d6"
        case .uniF1D7Icon: return "unif1d7"
        case .uniF1E0Icon: return "unif1e0"
        case .uniF1F0Icon: return "unif1f0"
        case .uniF280Icon: return "unif280"
        case .uniF281Icon: return "unif281"
        case .uniF285Icon: return "unif285"
        case .uniF286Icon: return "unif286"
        case .uniF2A0Icon: return "unif2a0"
        case .uniF2A1Icon: return "unif2a1"
        case .uniF2A2Icon: return "unif2a2"
        case .uniF2A3Icon: return "unif2a3"
        case .uniF2A4Icon: return "unif2a4"
        case .uniF2A5Icon: return "unif2a5"
        case .uniF2A6Icon: return "unif2a6"
        case .uniF2A7Icon: return "unif2a7"
        case .uniF2A8Icon: return "unif2a8"
        case .uniF2A9Icon: return "unif2a9"
        case .uniF2AAIcon: return "unif2aa"
        case .uniF2ABIcon: return "unif2ab"
        case .uniF2ACIcon: return "unif2ac"
        case .uniF2ADIcon: return "unif2ad"
        case .uniF2AEIcon: return "unif2ae"
        case .uniF2B0Icon: return "unif2b0"
        case .uniF2B1Icon: return "unif2b1"
        case .uniF2B2Icon: return "unif2b2"
        case .uniF2B3Icon: return "unif2b3"
        case .uniF2B4Icon: return "unif2b4"
        case .uniF2B5Icon: return "unif2b5"
        case .uniF2B6Icon: return "unif2b6"
        case .uniF2B7Icon: return "unif2b7"
        case .uniF2B8Icon: return "unif2b8"
        case .uniF2B9Icon: return "unif2b9"
        case .uniF2BAIcon: return "unif2ba"
        case .uniF2BBIcon: return "unif2bb"
        case .uniF2BCIcon: return "unif2bc"
        case .uniF2BDIcon: return "unif2bd"
        case .uniF2BEIcon: return "unif2be"
        case .uniF2C0Icon: return "unif2c0"
        case .uniF2C1Icon: return "unif2c1"
        case .uniF2C2Icon: return "unif2c2"
        case .uniF2C3Icon: return "unif2c3"
        case .uniF2C4Icon: return "unif2c4"
        case .uniF2C5Icon: return "unif2c5"
        case .uniF2C6Icon: return "unif2c6"
        case .uniF2C7Icon: return "unif2c7"
        case .uniF2C8Icon: return "unif2c8"
        case .uniF2C9Icon: return "unif2c9"
        case .uniF2CAIcon: return "unif2ca"
        case .uniF2CBIcon: return "unif2cb"
        case .uniF2CCIcon: return "unif2cc"
        case .uniF2CDIcon: return "unif2cd"
        case .uniF2CEIcon: return "unif2ce"
        case .uniF2D0Icon: return "unif2d0"
        case .uniF2D1Icon: return "unif2d1"
        case .uniF2D2Icon: return "unif2d2"
        case .uniF2D3Icon: return "unif2d3"
        case .uniF2D4Icon: return "unif2d4"
        case .uniF2D5Icon: return "unif2d5"
        case .uniF2D6Icon: return "unif2d6"
        case .uniF2D7Icon: return "unif2d7"
        case .uniF2D8Icon: return "unif2d8"
        case .uniF2D9Icon: return "unif2d9"
        case .uniF2DAIcon: return "unif2da"
        case .uniF2DBIcon: return "unif2db"
        case .uniF2DCIcon: return "unif2dc"
        case .uniF2DDIcon: return "unif2dd"
        case .uniF2DEIcon: return "unif2de"
        case .uniF2E0Icon: return "unif2e0"
        case .uniF2E1Icon: return "unif2e1"
        case .uniF2E2Icon: return "unif2e2"
        case .uniF2E3Icon: return "unif2e3"
        case .uniF2E4Icon: return "unif2e4"
        case .uniF2E5Icon: return "unif2e5"
        case .uniF2E6Icon: return "unif2e6"
        case .uniF2E7Icon: return "unif2e7"
        case .uniF2E9Icon: return "unif2e9"
        case .uniF2EAIcon: return "unif2ea"
        case .uniF2EBIcon: return "unif2eb"
        case .uniF2ECIcon: return "unif2ec"
        case .uniF2EDIcon: return "unif2ed"
        case .uniF2EEIcon: return "unif2ee"
        case .unlinkIcon: return "unlink"
        case .unlockIcon: return "unlock"
        case .unlockAltIcon: return "unlock_alt"
        case .uploadIcon: return "upload"
        case .uploadAltIcon: return "upload_alt"
        case .usdIcon: return "usd"
        case .userIcon: return "user"
        case .userMdIcon: return "user_md"
        case .venusIcon: return "venus"
        case .vimeoSquareIcon: return "vimeo_square"
        case .vkIcon: return "vk"
        case .volumeDownIcon: return "volume_down"
        case .volumeOffIcon: return "volume_off"
        case .volumeUpIcon: return "volume_up"
        case .warningSignIcon: return "warning_sign"
        case .weiboIcon: return "weibo"
        case .windowsIcon: return "windows"
        case .wrenchIcon: return "wrench"
        case .xingIcon: return "xing"
        case .xingSignIcon: return "xing_sign"
        case .youtubeIcon: return "youtube"
        case .youtubePlayIcon: return "youtube_play"
        case .youtubeSignIcon: return "youtube_sign"
        case .zoomInIcon: return "zoom_in"
        case .zoomOutIcon: return "zoom_out"
        }
    }
    /** The icon's unicode. */
    public var unicode: String {
        switch self {
        case ._279Icon: return "\u{F129}"
        case ._283Icon: return "\u{F12D}"
        case ._303Icon: return "\u{F143}"
        case ._312Icon: return "\u{F14C}"
        case ._317Icon: return "\u{F152}"
        case ._329Icon: return "\u{F15E}"
        case ._334Icon: return "\u{F164}"
        case ._335Icon: return "\u{F165}"
        case ._366Icon: return "\u{F186}"
        case ._372Icon: return "\u{F18C}"
        case ._374Icon: return "\u{F18E}"
        case ._376Icon: return "\u{F191}"
        case ._378Icon: return "\u{F193}"
        case ._380Icon: return "\u{F195}"
        case ._382Icon: return "\u{F197}"
        case ._383Icon: return "\u{F198}"
        case ._384Icon: return "\u{F199}"
        case ._385Icon: return "\u{F19A}"
        case ._386Icon: return "\u{F19B}"
        case ._387Icon: return "\u{F19C}"
        case ._388Icon: return "\u{F19D}"
        case ._389Icon: return "\u{F19E}"
        case ._392Icon: return "\u{F1A2}"
        case ._393Icon: return "\u{F1A3}"
        case ._395Icon: return "\u{F1A5}"
        case ._396Icon: return "\u{F1A6}"
        case ._397Icon: return "\u{F1A7}"
        case ._398Icon: return "\u{F1A8}"
        case ._399Icon: return "\u{F1A9}"
        case ._400Icon: return "\u{F1AA}"
        case ._402Icon: return "\u{F1AC}"
        case ._403Icon: return "\u{F1AD}"
        case ._404Icon: return "\u{F1AE}"
        case ._406Icon: return "\u{F1B1}"
        case ._407Icon: return "\u{F1B2}"
        case ._408Icon: return "\u{F1B3}"
        case ._409Icon: return "\u{F1B4}"
        case ._410Icon: return "\u{F1B5}"
        case ._411Icon: return "\u{F1B6}"
        case ._412Icon: return "\u{F1B7}"
        case ._413Icon: return "\u{F1B8}"
        case ._414Icon: return "\u{F1B9}"
        case ._415Icon: return "\u{F1BA}"
        case ._416Icon: return "\u{F1BB}"
        case ._417Icon: return "\u{F1BC}"
        case ._418Icon: return "\u{F1BD}"
        case ._419Icon: return "\u{F1BE}"
        case ._422Icon: return "\u{F1C2}"
        case ._423Icon: return "\u{F1C3}"
        case ._424Icon: return "\u{F1C4}"
        case ._425Icon: return "\u{F1C5}"
        case ._426Icon: return "\u{F1C6}"
        case ._427Icon: return "\u{F1C7}"
        case ._428Icon: return "\u{F1C8}"
        case ._429Icon: return "\u{F1C9}"
        case ._430Icon: return "\u{F1CA}"
        case ._431Icon: return "\u{F1CB}"
        case ._432Icon: return "\u{F1CC}"
        case ._433Icon: return "\u{F1CD}"
        case ._434Icon: return "\u{F1CE}"
        case ._438Icon: return "\u{F1D3}"
        case ._439Icon: return "\u{F1D4}"
        case ._443Icon: return "\u{F1D8}"
        case ._444Icon: return "\u{F1D9}"
        case ._445Icon: return "\u{F1DA}"
        case ._446Icon: return "\u{F1DB}"
        case ._447Icon: return "\u{F1DC}"
        case ._448Icon: return "\u{F1DD}"
        case ._449Icon: return "\u{F1DE}"
        case ._451Icon: return "\u{F1E1}"
        case ._452Icon: return "\u{F1E2}"
        case ._453Icon: return "\u{F1E3}"
        case ._454Icon: return "\u{F1E4}"
        case ._455Icon: return "\u{F1E5}"
        case ._456Icon: return "\u{F1E6}"
        case ._457Icon: return "\u{F1E7}"
        case ._458Icon: return "\u{F1E8}"
        case ._459Icon: return "\u{F1E9}"
        case ._460Icon: return "\u{F1EA}"
        case ._461Icon: return "\u{F1EB}"
        case ._462Icon: return "\u{F1EC}"
        case ._463Icon: return "\u{F1ED}"
        case ._464Icon: return "\u{F1EE}"
        case ._466Icon: return "\u{F1F1}"
        case ._467Icon: return "\u{F1F2}"
        case ._469Icon: return "\u{F1F4}"
        case ._470Icon: return "\u{F1F5}"
        case ._471Icon: return "\u{F1F6}"
        case ._472Icon: return "\u{F1F7}"
        case ._473Icon: return "\u{F1F8}"
        case ._474Icon: return "\u{F1F9}"
        case ._475Icon: return "\u{F1FA}"
        case ._476Icon: return "\u{F1FB}"
        case ._478Icon: return "\u{F1FD}"
        case ._479Icon: return "\u{F1FE}"
        case ._480Icon: return "\u{F200}"
        case ._481Icon: return "\u{F201}"
        case ._482Icon: return "\u{F202}"
        case ._483Icon: return "\u{F203}"
        case ._484Icon: return "\u{F204}"
        case ._485Icon: return "\u{F205}"
        case ._486Icon: return "\u{F206}"
        case ._487Icon: return "\u{F207}"
        case ._488Icon: return "\u{F208}"
        case ._489Icon: return "\u{F209}"
        case ._490Icon: return "\u{F20A}"
        case ._491Icon: return "\u{F20B}"
        case ._492Icon: return "\u{F20C}"
        case ._493Icon: return "\u{F20D}"
        case ._494Icon: return "\u{F20E}"
        case ._496Icon: return "\u{F211}"
        case ._498Icon: return "\u{F213}"
        case ._499Icon: return "\u{F214}"
        case ._500Icon: return "\u{F215}"
        case ._501Icon: return "\u{F216}"
        case ._502Icon: return "\u{F217}"
        case ._503Icon: return "\u{F218}"
        case ._504Icon: return "\u{F219}"
        case ._505Icon: return "\u{F21A}"
        case ._506Icon: return "\u{F21B}"
        case ._507Icon: return "\u{F21C}"
        case ._508Icon: return "\u{F21D}"
        case ._509Icon: return "\u{F21E}"
        case ._511Icon: return "\u{F222}"
        case ._512Icon: return "\u{F223}"
        case ._513Icon: return "\u{F224}"
        case ._514Icon: return "\u{F225}"
        case ._515Icon: return "\u{F226}"
        case ._516Icon: return "\u{F227}"
        case ._517Icon: return "\u{F228}"
        case ._518Icon: return "\u{F229}"
        case ._519Icon: return "\u{F22A}"
        case ._520Icon: return "\u{F22B}"
        case ._521Icon: return "\u{F22C}"
        case ._522Icon: return "\u{F22D}"
        case ._523Icon: return "\u{F22E}"
        case ._524Icon: return "\u{F22F}"
        case ._525Icon: return "\u{F230}"
        case ._526Icon: return "\u{F231}"
        case ._527Icon: return "\u{F232}"
        case ._528Icon: return "\u{F233}"
        case ._529Icon: return "\u{F234}"
        case ._530Icon: return "\u{F235}"
        case ._531Icon: return "\u{F236}"
        case ._532Icon: return "\u{F237}"
        case ._533Icon: return "\u{F238}"
        case ._534Icon: return "\u{F239}"
        case ._535Icon: return "\u{F23A}"
        case ._536Icon: return "\u{F23B}"
        case ._537Icon: return "\u{F23C}"
        case ._538Icon: return "\u{F23D}"
        case ._539Icon: return "\u{F23E}"
        case ._540Icon: return "\u{F240}"
        case ._541Icon: return "\u{F241}"
        case ._542Icon: return "\u{F242}"
        case ._543Icon: return "\u{F243}"
        case ._544Icon: return "\u{F244}"
        case ._545Icon: return "\u{F245}"
        case ._546Icon: return "\u{F246}"
        case ._547Icon: return "\u{F247}"
        case ._548Icon: return "\u{F248}"
        case ._549Icon: return "\u{F249}"
        case ._550Icon: return "\u{F24A}"
        case ._551Icon: return "\u{F24B}"
        case ._552Icon: return "\u{F24C}"
        case ._553Icon: return "\u{F24D}"
        case ._554Icon: return "\u{F24E}"
        case ._555Icon: return "\u{F250}"
        case ._556Icon: return "\u{F251}"
        case ._557Icon: return "\u{F252}"
        case ._558Icon: return "\u{F253}"
        case ._559Icon: return "\u{F254}"
        case ._560Icon: return "\u{F255}"
        case ._561Icon: return "\u{F256}"
        case ._562Icon: return "\u{F257}"
        case ._563Icon: return "\u{F258}"
        case ._564Icon: return "\u{F259}"
        case ._565Icon: return "\u{F25A}"
        case ._566Icon: return "\u{F25B}"
        case ._567Icon: return "\u{F25C}"
        case ._568Icon: return "\u{F25D}"
        case ._569Icon: return "\u{F25E}"
        case ._572Icon: return "\u{F262}"
        case ._574Icon: return "\u{F264}"
        case ._575Icon: return "\u{F265}"
        case ._576Icon: return "\u{F266}"
        case ._577Icon: return "\u{F267}"
        case ._578Icon: return "\u{F268}"
        case ._579Icon: return "\u{F269}"
        case ._580Icon: return "\u{F26A}"
        case ._581Icon: return "\u{F26B}"
        case ._582Icon: return "\u{F26C}"
        case ._583Icon: return "\u{F26D}"
        case ._584Icon: return "\u{F26E}"
        case ._585Icon: return "\u{F270}"
        case ._586Icon: return "\u{F271}"
        case ._587Icon: return "\u{F272}"
        case ._588Icon: return "\u{F273}"
        case ._589Icon: return "\u{F274}"
        case ._590Icon: return "\u{F275}"
        case ._591Icon: return "\u{F276}"
        case ._592Icon: return "\u{F277}"
        case ._593Icon: return "\u{F278}"
        case ._594Icon: return "\u{F279}"
        case ._595Icon: return "\u{F27A}"
        case ._596Icon: return "\u{F27B}"
        case ._597Icon: return "\u{F27C}"
        case ._598Icon: return "\u{F27D}"
        case ._602Icon: return "\u{F282}"
        case ._603Icon: return "\u{F283}"
        case ._604Icon: return "\u{F284}"
        case ._607Icon: return "\u{F287}"
        case ._608Icon: return "\u{F288}"
        case ._609Icon: return "\u{F289}"
        case ._610Icon: return "\u{F28A}"
        case ._611Icon: return "\u{F28B}"
        case ._612Icon: return "\u{F28C}"
        case ._613Icon: return "\u{F28D}"
        case ._614Icon: return "\u{F28E}"
        case ._615Icon: return "\u{F290}"
        case ._616Icon: return "\u{F291}"
        case ._617Icon: return "\u{F292}"
        case ._618Icon: return "\u{F293}"
        case ._619Icon: return "\u{F294}"
        case ._620Icon: return "\u{F295}"
        case ._621Icon: return "\u{F296}"
        case ._622Icon: return "\u{F297}"
        case ._623Icon: return "\u{F298}"
        case ._624Icon: return "\u{F299}"
        case ._625Icon: return "\u{F29A}"
        case ._626Icon: return "\u{F29B}"
        case ._627Icon: return "\u{F29C}"
        case ._628Icon: return "\u{F29D}"
        case ._629Icon: return "\u{F29E}"
        case ._698Icon: return "\u{F2E8}"
        case .adjustIcon: return "\u{F042}"
        case .adnIcon: return "\u{F170}"
        case .alignCenterIcon: return "\u{F037}"
        case .alignJustifyIcon: return "\u{F039}"
        case .alignLeftIcon: return "\u{F036}"
        case .alignRightIcon: return "\u{F038}"
        case .ambulanceIcon: return "\u{F0F9}"
        case .anchorIcon: return "\u{F13D}"
        case .androidIcon: return "\u{F17B}"
        case .angleDownIcon: return "\u{F107}"
        case .angleLeftIcon: return "\u{F104}"
        case .angleRightIcon: return "\u{F105}"
        case .angleUpIcon: return "\u{F106}"
        case .appleIcon: return "\u{F179}"
        case .archiveIcon: return "\u{F187}"
        case .arrowCircleAltLeftIcon: return "\u{F190}"
        case .arrowDownIcon: return "\u{F063}"
        case .arrowLeftIcon: return "\u{F060}"
        case .arrowRightIcon: return "\u{F061}"
        case .arrowUpIcon: return "\u{F062}"
        case .asteriskIcon: return "\u{F069}"
        case .backwardIcon: return "\u{F04A}"
        case .banCircleIcon: return "\u{F05E}"
        case .barChartIcon: return "\u{F080}"
        case .barcodeIcon: return "\u{F02A}"
        case .beakerIcon: return "\u{F0C3}"
        case .beerIcon: return "\u{F0FC}"
        case .bellIcon: return "\u{F0A2}"
        case .bellAltIcon: return "\u{F0F3}"
        case .bitbucketSignIcon: return "\u{F172}"
        case .boldIcon: return "\u{F032}"
        case .boltIcon: return "\u{F0E7}"
        case .bookIcon: return "\u{F02D}"
        case .bookmarkIcon: return "\u{F02E}"
        case .bookmarkEmptyIcon: return "\u{F097}"
        case .briefcaseIcon: return "\u{F0B1}"
        case .btcIcon: return "\u{F15A}"
        case .bugIcon: return "\u{F188}"
        case .buildingIcon: return "\u{F0F7}"
        case .bullhornIcon: return "\u{F0A1}"
        case .bullseyeIcon: return "\u{F140}"
        case .calendarIcon: return "\u{F073}"
        case .calendarEmptyIcon: return "\u{F133}"
        case .cameraIcon: return "\u{F030}"
        case .cameraRetroIcon: return "\u{F083}"
        case .caretDownIcon: return "\u{F0D7}"
        case .caretLeftIcon: return "\u{F0D9}"
        case .caretRightIcon: return "\u{F0DA}"
        case .caretUpIcon: return "\u{F0D8}"
        case .certificateIcon: return "\u{F0A3}"
        case .checkIcon: return "\u{F046}"
        case .checkEmptyIcon: return "\u{F096}"
        case .checkMinusIcon: return "\u{F147}"
        case .checkSignIcon: return "\u{F14A}"
        case .chevronDownIcon: return "\u{F078}"
        case .chevronLeftIcon: return "\u{F053}"
        case .chevronRightIcon: return "\u{F054}"
        case .chevronSignDownIcon: return "\u{F13A}"
        case .chevronSignLeftIcon: return "\u{F137}"
        case .chevronSignRightIcon: return "\u{F138}"
        case .chevronSignUpIcon: return "\u{F139}"
        case .chevronUpIcon: return "\u{F077}"
        case .circleIcon: return "\u{F111}"
        case .circleArrowDownIcon: return "\u{F0AB}"
        case .circleArrowLeftIcon: return "\u{F0A8}"
        case .circleArrowRightIcon: return "\u{F0A9}"
        case .circleArrowUpIcon: return "\u{F0AA}"
        case .circleBlankIcon: return "\u{F10C}"
        case .cloudIcon: return "\u{F0C2}"
        case .cloudDownloadIcon: return "\u{F0ED}"
        case .cloudUploadIcon: return "\u{F0EE}"
        case .codeIcon: return "\u{F121}"
        case .codeForkIcon: return "\u{F126}"
        case .coffeeIcon: return "\u{F0F4}"
        case .cogIcon: return "\u{F013}"
        case .cogsIcon: return "\u{F085}"
        case .collapseIcon: return "\u{F150}"
        case .collapseAltIcon: return "\u{F117}"
        case .collapseTopIcon: return "\u{F151}"
        case .columnsIcon: return "\u{F0DB}"
        case .commentIcon: return "\u{F075}"
        case .commentAltIcon: return "\u{F0E5}"
        case .commentsIcon: return "\u{F086}"
        case .commentsAltIcon: return "\u{F0E6}"
        case .compassIcon: return "\u{F14E}"
        case .copyIcon: return "\u{F0C5}"
        case .creditCardIcon: return "\u{F09D}"
        case .cropIcon: return "\u{F125}"
        case .css3Icon: return "\u{F13C}"
        case .cutIcon: return "\u{F0C4}"
        case .dashboardIcon: return "\u{F0E4}"
        case .desktopIcon: return "\u{F108}"
        case .dotCircleAltIcon: return "\u{F192}"
        case .doubleAngleDownIcon: return "\u{F103}"
        case .doubleAngleLeftIcon: return "\u{F100}"
        case .doubleAngleRightIcon: return "\u{F101}"
        case .doubleAngleUpIcon: return "\u{F102}"
        case .downloadIcon: return "\u{F01A}"
        case .downloadAltIcon: return "\u{F019}"
        case .dribbleIcon: return "\u{F17D}"
        case .dropboxIcon: return "\u{F16B}"
        case .editIcon: return "\u{F044}"
        case .editSignIcon: return "\u{F14B}"
        case .ejectIcon: return "\u{F052}"
        case .ellipsisHorizontalIcon: return "\u{F141}"
        case .ellipsisVerticalIcon: return "\u{F142}"
        case .envelopeIcon: return "\u{F003}"
        case .envelopeAltIcon: return "\u{F0E0}"
        case .eurIcon: return "\u{F153}"
        case .exchangeIcon: return "\u{F0EC}"
        case .exclamationIcon: return "\u{F12A}"
        case .exclamationSignIcon: return "\u{F06A}"
        case .expandAltIcon: return "\u{F116}"
        case .externalLinkIcon: return "\u{F08E}"
        case .eyeCloseIcon: return "\u{F070}"
        case .eyeOpenIcon: return "\u{F06E}"
        case .f0feIcon: return "\u{F0FE}"
        case .f171Icon: return "\u{F171}"
        case .f1a1Icon: return "\u{F1A1}"
        case .f1a4Icon: return "\u{F1A4}"
        case .f1abIcon: return "\u{F1AB}"
        case .f1f3Icon: return "\u{F1F3}"
        case .f1fcIcon: return "\u{F1FC}"
        case .f210Icon: return "\u{F210}"
        case .f212Icon: return "\u{F212}"
        case .f260Icon: return "\u{F260}"
        case .f261Icon: return "\u{F261}"
        case .f263Icon: return "\u{F263}"
        case .f27eIcon: return "\u{F27E}"
        case .facebookIcon: return "\u{F09A}"
        case .facebookSignIcon: return "\u{F082}"
        case .facetimeVideoIcon: return "\u{F03D}"
        case .fastBackwardIcon: return "\u{F049}"
        case .fastForwardIcon: return "\u{F050}"
        case .femaleIcon: return "\u{F182}"
        case .fighterJetIcon: return "\u{F0FB}"
        case .fileIcon: return "\u{F15B}"
        case .fileAltIcon: return "\u{F016}"
        case .fileTextIcon: return "\u{F15C}"
        case .fileTextAltIcon: return "\u{F0F6}"
        case .filmIcon: return "\u{F008}"
        case .filterIcon: return "\u{F0B0}"
        case .fireIcon: return "\u{F06D}"
        case .fireExtinguisherIcon: return "\u{F134}"
        case .flagIcon: return "\u{F024}"
        case .flagAltIcon: return "\u{F11D}"
        case .flagCheckeredIcon: return "\u{F11E}"
        case .flickrIcon: return "\u{F16E}"
        case .folderCloseIcon: return "\u{F07B}"
        case .folderCloseAltIcon: return "\u{F114}"
        case .folderOpenIcon: return "\u{F07C}"
        case .folderOpenAltIcon: return "\u{F115}"
        case .fontIcon: return "\u{F031}"
        case .foodIcon: return "\u{F0F5}"
        case .forwardIcon: return "\u{F04E}"
        case .foursquareIcon: return "\u{F180}"
        case .frownIcon: return "\u{F119}"
        case .fullscreenIcon: return "\u{F0B2}"
        case .gamepadIcon: return "\u{F11B}"
        case .gbpIcon: return "\u{F154}"
        case .giftIcon: return "\u{F06B}"
        case .githubIcon: return "\u{F09B}"
        case .githubAltIcon: return "\u{F113}"
        case .githubSignIcon: return "\u{F092}"
        case .gittipIcon: return "\u{F184}"
        case .glassIcon: return "\u{F000}"
        case .globeIcon: return "\u{F0AC}"
        case .googlePlusIcon: return "\u{F0D5}"
        case .googlePlusSignIcon: return "\u{F0D4}"
        case .groupIcon: return "\u{F0C0}"
        case .hSignIcon: return "\u{F0FD}"
        case .handDownIcon: return "\u{F0A7}"
        case .handLeftIcon: return "\u{F0A5}"
        case .handRightIcon: return "\u{F0A4}"
        case .handUpIcon: return "\u{F0A6}"
        case .hddIcon: return "\u{F0A0}"
        case .headphonesIcon: return "\u{F025}"
        case .heartIcon: return "\u{F004}"
        case .heartEmptyIcon: return "\u{F08A}"
        case .homeIcon: return "\u{F015}"
        case .hospitalIcon: return "\u{F0F8}"
        case .html5Icon: return "\u{F13B}"
        case .inboxIcon: return "\u{F01C}"
        case .indentLeftIcon: return "\u{F03B}"
        case .indentRightIcon: return "\u{F03C}"
        case .infoSignIcon: return "\u{F05A}"
        case .inrIcon: return "\u{F156}"
        case .instagramIcon: return "\u{F16D}"
        case .italicIcon: return "\u{F033}"
        case .jpyIcon: return "\u{F157}"
        case .keyIcon: return "\u{F084}"
        case .keyboardIcon: return "\u{F11C}"
        case .krwIcon: return "\u{F159}"
        case .laptopIcon: return "\u{F109}"
        case .leafIcon: return "\u{F06C}"
        case .legalIcon: return "\u{F0E3}"
        case .lemonIcon: return "\u{F094}"
        case .lessequalIcon: return "\u{F500}"
        case .levelDownIcon: return "\u{F149}"
        case .levelUpIcon: return "\u{F148}"
        case .lightBulbIcon: return "\u{F0EB}"
        case .linkIcon: return "\u{F0C1}"
        case .linkedinIcon: return "\u{F0E1}"
        case .linkedinSignIcon: return "\u{F08C}"
        case .linuxIcon: return "\u{F17C}"
        case .listIcon: return "\u{F03A}"
        case .listAltIcon: return "\u{F022}"
        case .locationArrowIcon: return "\u{F124}"
        case .lockIcon: return "\u{F023}"
        case .longArrowDownIcon: return "\u{F175}"
        case .longArrowLeftIcon: return "\u{F177}"
        case .longArrowRightIcon: return "\u{F178}"
        case .longArrowUpIcon: return "\u{F176}"
        case .magicIcon: return "\u{F0D0}"
        case .magnetIcon: return "\u{F076}"
        case .maleIcon: return "\u{F183}"
        case .mapMarkerIcon: return "\u{F041}"
        case .maxcdnIcon: return "\u{F136}"
        case .medkitIcon: return "\u{F0FA}"
        case .mehIcon: return "\u{F11A}"
        case .microphoneIcon: return "\u{F130}"
        case .microphoneOffIcon: return "\u{F131}"
        case .minusIcon: return "\u{F068}"
        case .minusSignIcon: return "\u{F056}"
        case .minusSignAltIcon: return "\u{F146}"
        case .mobilePhoneIcon: return "\u{F10B}"
        case .moneyIcon: return "\u{F0D6}"
        case .moveIcon: return "\u{F047}"
        case .musicIcon: return "\u{F001}"
        case .offIcon: return "\u{F011}"
        case .okIcon: return "\u{F00C}"
        case .okCircleIcon: return "\u{F05D}"
        case .okSignIcon: return "\u{F058}"
        case .olIcon: return "\u{F0CB}"
        case .paperClipIcon: return "\u{F0C6}"
        case .pasteIcon: return "\u{F0EA}"
        case .pauseIcon: return "\u{F04C}"
        case .pencilIcon: return "\u{F040}"
        case .phoneIcon: return "\u{F095}"
        case .phoneSignIcon: return "\u{F098}"
        case .pictureIcon: return "\u{F03E}"
        case .pinterestIcon: return "\u{F0D2}"
        case .pinterestSignIcon: return "\u{F0D3}"
        case .planeIcon: return "\u{F072}"
        case .playIcon: return "\u{F04B}"
        case .playCircleIcon: return "\u{F01D}"
        case .playSignIcon: return "\u{F144}"
        case .plusIcon: return "\u{F067}"
        case .plusSignIcon: return "\u{F055}"
        case .plusSquareOIcon: return "\u{F196}"
        case .printIcon: return "\u{F02F}"
        case .pushpinIcon: return "\u{F08D}"
        case .puzzlePieceIcon: return "\u{F12E}"
        case .qrcodeIcon: return "\u{F029}"
        case .questionIcon: return "\u{F128}"
        case .questionSignIcon: return "\u{F059}"
        case .quoteLeftIcon: return "\u{F10D}"
        case .quoteRightIcon: return "\u{F10E}"
        case .randomIcon: return "\u{F074}"
        case .refreshIcon: return "\u{F021}"
        case .removeIcon: return "\u{F00D}"
        case .removeCircleIcon: return "\u{F05C}"
        case .removeSignIcon: return "\u{F057}"
        case .renrenIcon: return "\u{F18B}"
        case .reorderIcon: return "\u{F0C9}"
        case .repeatIcon: return "\u{F01E}"
        case .replyIcon: return "\u{F112}"
        case .replyAllIcon: return "\u{F122}"
        case .resizeFullIcon: return "\u{F065}"
        case .resizeHorizontalIcon: return "\u{F07E}"
        case .resizeSmallIcon: return "\u{F066}"
        case .resizeVerticalIcon: return "\u{F07D}"
        case .retweetIcon: return "\u{F079}"
        case .roadIcon: return "\u{F018}"
        case .rocketIcon: return "\u{F135}"
        case .rssIcon: return "\u{F09E}"
        case .rubIcon: return "\u{F158}"
        case .saveIcon: return "\u{F0C7}"
        case .screenshotIcon: return "\u{F05B}"
        case .searchIcon: return "\u{F002}"
        case .shareIcon: return "\u{F045}"
        case .shareAltIcon: return "\u{F064}"
        case .shareSignIcon: return "\u{F14D}"
        case .shieldIcon: return "\u{F132}"
        case .shoppingCartIcon: return "\u{F07A}"
        case .signBlankIcon: return "\u{F0C8}"
        case .signalIcon: return "\u{F012}"
        case .signinIcon: return "\u{F090}"
        case .signoutIcon: return "\u{F08B}"
        case .sitemapIcon: return "\u{F0E8}"
        case .skypeIcon: return "\u{F17E}"
        case .smileIcon: return "\u{F118}"
        case .sortIcon: return "\u{F0DC}"
        case .sortByAlphabetIcon: return "\u{F15D}"
        case .sortByAttributesIcon: return "\u{F160}"
        case .sortByAttributesAltIcon: return "\u{F161}"
        case .sortByOrderIcon: return "\u{F162}"
        case .sortByOrderAltIcon: return "\u{F163}"
        case .sortDownIcon: return "\u{F0DD}"
        case .sortUpIcon: return "\u{F0DE}"
        case .spinnerIcon: return "\u{F110}"
        case .stackExchangeIcon: return "\u{F18D}"
        case .stackexchangeIcon: return "\u{F16C}"
        case .starIcon: return "\u{F005}"
        case .starEmptyIcon: return "\u{F006}"
        case .starHalfIcon: return "\u{F089}"
        case .starHalfEmptyIcon: return "\u{F123}"
        case .stepBackwardIcon: return "\u{F048}"
        case .stepForwardIcon: return "\u{F051}"
        case .stethoscopeIcon: return "\u{F0F1}"
        case .stopIcon: return "\u{F04D}"
        case .strikethroughIcon: return "\u{F0CC}"
        case .subscriptIcon: return "\u{F12C}"
        case .suitcaseIcon: return "\u{F0F2}"
        case .sunIcon: return "\u{F185}"
        case .superscriptIcon: return "\u{F12B}"
        case .tableIcon: return "\u{F0CE}"
        case .tabletIcon: return "\u{F10A}"
        case .tagIcon: return "\u{F02B}"
        case .tagsIcon: return "\u{F02C}"
        case .tasksIcon: return "\u{F0AE}"
        case .terminalIcon: return "\u{F120}"
        case .textHeightIcon: return "\u{F034}"
        case .textWidthIcon: return "\u{F035}"
        case .thIcon: return "\u{F00A}"
        case .thLargeIcon: return "\u{F009}"
        case .thListIcon: return "\u{F00B}"
        case .thumbsDownAltIcon: return "\u{F088}"
        case .thumbsUpAltIcon: return "\u{F087}"
        case .ticketIcon: return "\u{F145}"
        case .timeIcon: return "\u{F017}"
        case .tintIcon: return "\u{F043}"
        case .trashIcon: return "\u{F014}"
        case .trelloIcon: return "\u{F181}"
        case .trophyIcon: return "\u{F091}"
        case .truckIcon: return "\u{F0D1}"
        case .tumblrIcon: return "\u{F173}"
        case .tumblrSignIcon: return "\u{F174}"
        case .twitterIcon: return "\u{F099}"
        case .twitterSignIcon: return "\u{F081}"
        case .ulIcon: return "\u{F0CA}"
        case .umbrellaIcon: return "\u{F0E9}"
        case .underlineIcon: return "\u{F0CD}"
        case .undoIcon: return "\u{F0E2}"
        case .uniF1A0Icon: return "\u{F1A0}"
        case .uniF1B1Icon: return "\u{F1B0}"
        case .uniF1C0Icon: return "\u{F1C0}"
        case .uniF1C1Icon: return "\u{F1C1}"
        case .uniF1D0Icon: return "\u{F1D0}"
        case .uniF1D1Icon: return "\u{F1D1}"
        case .uniF1D2Icon: return "\u{F1D2}"
        case .uniF1D5Icon: return "\u{F1D5}"
        case .uniF1D6Icon: return "\u{F1D6}"
        case .uniF1D7Icon: return "\u{F1D7}"
        case .uniF1E0Icon: return "\u{F1E0}"
        case .uniF1F0Icon: return "\u{F1F0}"
        case .uniF280Icon: return "\u{F280}"
        case .uniF281Icon: return "\u{F281}"
        case .uniF285Icon: return "\u{F285}"
        case .uniF286Icon: return "\u{F286}"
        case .uniF2A0Icon: return "\u{F2A0}"
        case .uniF2A1Icon: return "\u{F2A1}"
        case .uniF2A2Icon: return "\u{F2A2}"
        case .uniF2A3Icon: return "\u{F2A3}"
        case .uniF2A4Icon: return "\u{F2A4}"
        case .uniF2A5Icon: return "\u{F2A5}"
        case .uniF2A6Icon: return "\u{F2A6}"
        case .uniF2A7Icon: return "\u{F2A7}"
        case .uniF2A8Icon: return "\u{F2A8}"
        case .uniF2A9Icon: return "\u{F2A9}"
        case .uniF2AAIcon: return "\u{F2AA}"
        case .uniF2ABIcon: return "\u{F2AB}"
        case .uniF2ACIcon: return "\u{F2AC}"
        case .uniF2ADIcon: return "\u{F2AD}"
        case .uniF2AEIcon: return "\u{F2AE}"
        case .uniF2B0Icon: return "\u{F2B0}"
        case .uniF2B1Icon: return "\u{F2B1}"
        case .uniF2B2Icon: return "\u{F2B2}"
        case .uniF2B3Icon: return "\u{F2B3}"
        case .uniF2B4Icon: return "\u{F2B4}"
        case .uniF2B5Icon: return "\u{F2B5}"
        case .uniF2B6Icon: return "\u{F2B6}"
        case .uniF2B7Icon: return "\u{F2B7}"
        case .uniF2B8Icon: return "\u{F2B8}"
        case .uniF2B9Icon: return "\u{F2B9}"
        case .uniF2BAIcon: return "\u{F2BA}"
        case .uniF2BBIcon: return "\u{F2BB}"
        case .uniF2BCIcon: return "\u{F2BC}"
        case .uniF2BDIcon: return "\u{F2BD}"
        case .uniF2BEIcon: return "\u{F2BE}"
        case .uniF2C0Icon: return "\u{F2C0}"
        case .uniF2C1Icon: return "\u{F2C1}"
        case .uniF2C2Icon: return "\u{F2C2}"
        case .uniF2C3Icon: return "\u{F2C3}"
        case .uniF2C4Icon: return "\u{F2C4}"
        case .uniF2C5Icon: return "\u{F2C5}"
        case .uniF2C6Icon: return "\u{F2C6}"
        case .uniF2C7Icon: return "\u{F2C7}"
        case .uniF2C8Icon: return "\u{F2C8}"
        case .uniF2C9Icon: return "\u{F2C9}"
        case .uniF2CAIcon: return "\u{F2CA}"
        case .uniF2CBIcon: return "\u{F2CB}"
        case .uniF2CCIcon: return "\u{F2CC}"
        case .uniF2CDIcon: return "\u{F2CD}"
        case .uniF2CEIcon: return "\u{F2CE}"
        case .uniF2D0Icon: return "\u{F2D0}"
        case .uniF2D1Icon: return "\u{F2D1}"
        case .uniF2D2Icon: return "\u{F2D2}"
        case .uniF2D3Icon: return "\u{F2D3}"
        case .uniF2D4Icon: return "\u{F2D4}"
        case .uniF2D5Icon: return "\u{F2D5}"
        case .uniF2D6Icon: return "\u{F2D6}"
        case .uniF2D7Icon: return "\u{F2D7}"
        case .uniF2D8Icon: return "\u{F2D8}"
        case .uniF2D9Icon: return "\u{F2D9}"
        case .uniF2DAIcon: return "\u{F2DA}"
        case .uniF2DBIcon: return "\u{F2DB}"
        case .uniF2DCIcon: return "\u{F2DC}"
        case .uniF2DDIcon: return "\u{F2DD}"
        case .uniF2DEIcon: return "\u{F2DE}"
        case .uniF2E0Icon: return "\u{F2E0}"
        case .uniF2E1Icon: return "\u{F2E1}"
        case .uniF2E2Icon: return "\u{F2E2}"
        case .uniF2E3Icon: return "\u{F2E3}"
        case .uniF2E4Icon: return "\u{F2E4}"
        case .uniF2E5Icon: return "\u{F2E5}"
        case .uniF2E6Icon: return "\u{F2E6}"
        case .uniF2E7Icon: return "\u{F2E7}"
        case .uniF2E9Icon: return "\u{F2E9}"
        case .uniF2EAIcon: return "\u{F2EA}"
        case .uniF2EBIcon: return "\u{F2EB}"
        case .uniF2ECIcon: return "\u{F2EC}"
        case .uniF2EDIcon: return "\u{F2ED}"
        case .uniF2EEIcon: return "\u{F2EE}"
        case .unlinkIcon: return "\u{F127}"
        case .unlockIcon: return "\u{F09C}"
        case .unlockAltIcon: return "\u{F13E}"
        case .uploadIcon: return "\u{F01B}"
        case .uploadAltIcon: return "\u{F093}"
        case .usdIcon: return "\u{F155}"
        case .userIcon: return "\u{F007}"
        case .userMdIcon: return "\u{F0F0}"
        case .venusIcon: return "\u{F221}"
        case .vimeoSquareIcon: return "\u{F194}"
        case .vkIcon: return "\u{F189}"
        case .volumeDownIcon: return "\u{F027}"
        case .volumeOffIcon: return "\u{F026}"
        case .volumeUpIcon: return "\u{F028}"
        case .warningSignIcon: return "\u{F071}"
        case .weiboIcon: return "\u{F18A}"
        case .windowsIcon: return "\u{F17A}"
        case .wrenchIcon: return "\u{F0AD}"
        case .xingIcon: return "\u{F168}"
        case .xingSignIcon: return "\u{F169}"
        case .youtubeIcon: return "\u{F167}"
        case .youtubePlayIcon: return "\u{F16A}"
        case .youtubeSignIcon: return "\u{F166}"
        case .zoomInIcon: return "\u{F00E}"
        case .zoomOutIcon: return "\u{F010}"
        }
    }
}
