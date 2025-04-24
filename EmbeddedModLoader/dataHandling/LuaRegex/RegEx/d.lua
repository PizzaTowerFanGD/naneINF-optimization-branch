self:remove_from_deck()
if self.ability.queue_negative_removal then
    if self.ability.consumeable then
        G.consumeables.config.card_limit = G.consumeables.config.card_limit - 1
    else
        G.jokers.config.card_limit = G.jokers.config.card_limit - 1
    end
end


if not G.OVERLAY_MENU then
    for k, v in pairs(G.P_CENTERS) do
        if v.name == self.ability.name then
            if not next(find_joker(self.ability.name, true)) then
                G.GAME.used_jokers[k] = nil
            end
        end
    end
end

if G.playing_cards then
    for k, v in ipairs(G.playing_cards) do
        if v == self then
            table.remove(G.playing_cards, k)
            break
        end
    end
    for k, v in ipairs(G.playing_cards) do
        v.playing_card = k
    end
end
