local fConfigureSidebarTheming = nil;
local fOnShortcutDropOnPortrait = nil;

function onInit()
	Interface.onDesktopInit = onDesktopInit;

	fOnShortcutDropOnPortrait = CharacterListManager.onShortcutDrop;
	CharacterListManager.registerDropHandler("shortcut", onShortcutDropOnPortrait);

	-- 2E doesn't use a sidebar, it uses better menus, so we don't configure the sidebar menu here.
	if not DeckedOut.isBetterMenusLoaded() then
		fConfigureSidebarTheming = DesktopManager.configureSidebarTheming;
		DesktopManager.configureSidebarTheming = configureSidebarTheming;
	end

	DesktopManager.setHandVisibility = setHandVisibility;
	DesktopManager.toggleHandVisibility = toggleHandVisibility;
	DesktopManager.openCardList = openCardList;
	DesktopManager.promptCardAmount = promptCardAmount;
end

function onDesktopInit()
	if Session.IsHost then 
		DesktopManager.setHandVisibility(CardManager.getNumberOfCardsInHand("gm") > 0);
	end
end

function configureSidebarTheming()
	fConfigureSidebarTheming();

	local nDockIconWidth = DesktopManager.getSidebarDockIconWidth();
	local nSidebarVisState = DesktopManager.getSidebarVisibilityState();
	local wShortcuts = DesktopManager.getSidebarWindow();

	if not wShortcuts then
		return;
	end

	wShortcuts.button_hand.setAnchoredHeight(nDockIconWidth);
	wShortcuts.button_hand_icon.setColor(DesktopManager.getSidebarDockIconColor());
end

-- Kind of janky, but this lets us ensure that the state of the button matches
-- incase we want to toggle the hand visibility outside of pressing the button
function setHandVisibility(bShowHand)
	-- 2e doesn't have a sidebar, so we can't use it to toggle hand visibility
	if not DeckedOut.isBetterMenusLoaded() then

		local window = DesktopManager.getSidebarWindow();
		if window then
			local nState = 0;
			if bShowHand then
				nState = 1;
			end
			window.button_hand.setValue(nState);
		end
	end

	DesktopManager.toggleHandVisibility(bShowHand);
end

function toggleHandVisibility(bShow)
	-- If we're a client that has no active identities, then this function
	-- should do nothing
	if not Session.IsHost and #(User.getActiveIdentities()) == 0 then
		return;
	end

	local window = Interface.findWindow("desktop_hand", "");
	if window then
		window.updateVisibility(bShow);
	end
end

function onShortcutDropOnPortrait(sIdentity, draginfo)
	local sClass, sRecord = draginfo.getShortcutData();
	local nodeSource = draginfo.getDatabaseNode();

	if sClass == "card" then
		CardManager.onDropCard(draginfo, DB.getPath("charsheet", sIdentity));
		return;
	end

	fOnShortcutDropOnPortrait(sIdentity, draginfo);
end

------------------------------------------
-- OTHER WINDOW FUNCTIONS
------------------------------------------
function openCardList(vSourceNode)
	local sTitle = DB.getValue(vSourceNode.getParent(), "name", "");
	if vSourceNode.getName() == DeckManager.DECK_DISCARD_PATH then
		sTitle = sTitle .. " (Discard)"
	end

	local window = Interface.openWindow("cardlist_viewer", vSourceNode);

	-- if StringManager.startsWith(vSourceNode.getNodeName(), "charsheet") then
	-- 	sTitle = DB.getValue(vSourceNode.getParent(), "name", "");
	-- else
	-- 	sTitle = DB.getValue(vSourceNode, "name", "");
	-- end

	-- window.setSource(sSource);
	window.setTitle(sTitle);
end

function promptCardAmount(fCallback)
	local w = Interface.openWindow("dealcards_dialog", "");
	w.setCallback(fCallback);
end