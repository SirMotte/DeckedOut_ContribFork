CARD_STORAGE_PATH = "deckbox.storage";

-- Indexed by the token string, contains the DB node in storage
local _storage =  {};

function onInit()
	if Session.IsHost then
		local storage = DB.createNode(CARD_STORAGE_PATH);
		DB.deleteChildren(storage);
		storage.setPublic(true);
	end
end

-----------------------------------------------------
-- EVENT FUNCTIONS
-----------------------------------------------------

---Adds a card to card storage. Raises the onAddedToStorage event
---@param vCard databasenode|string
---@param tEventTrace table Event trace table
---@return databasenode card The node that was added to card storage
function addCardToStorage(vCard, tEventTrace)
	local vCard = DeckedOutUtilities.validateCard(vCard);
	if not vCard then return end

	if CardStorage.isCardInStorage(vCard) then
		return CardStorage.getCardFromStorage(vCard);
	end

	local newCard = DB.copyNode(vCard, DB.createChild(CardStorage.getCardStorageNode()));
	local sToken = CardManager.getCardFront(vCard);
	_storage[sToken] = newCard;

	tEventTrace = DeckedOutEvents.raiseOnCardAddedToStorageEvent(newCard, tEventTrace);

	return newCard;
end

-----------------------------------------------------
-- HELPERS
-----------------------------------------------------

---Checks of a card is already in storage
---@param vCard databasenode|string
---@return boolean
function isCardInStorage(vCard)
	local vCard = DeckedOutUtilities.validateCard(vCard);
	if not vCard then return end

	local sToken = CardManager.getCardFront(vCard);
	return _storage[sToken] ~= nil;
end

---Gets a card from storage. Returns nil if card is not in storage
---@param vCard databasenode|string
---@return string tokenPrototype
function getCardFromStorage(vCard)
	local vCard = DeckedOutUtilities.validateCard(vCard);
	if not vCard then return end

	local sToken = CardManager.getCardFront(vCard);
	return _storage[sToken];
end

---Checks if a card node comes from the card storage node
---@param vCard databasenode|string
---@return boolean
function doesCardComeFromStorage(vCard)
	local vCard = DeckedOutUtilities.validateCard(vCard);
	if not vCard then return end

	local sNodeName = vCard.getNodeName();
	return StringManager.startsWith(sNodeName, CardStorage.CARD_STORAGE_PATH);
end

---Gets the card storage node
---@return string
function getCardStorageNode()
	return DB.findNode(CardStorage.CARD_STORAGE_PATH);
end