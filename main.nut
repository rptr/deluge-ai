require("util.nut");

class DelugeAI extends AIController
{
    x = null;
    y = null;
    tile = null;
    w = null;
    h = null;
    dirs = null;
    coasts = null;

    constructor ()
    {
        x = 0;
        y = 0;
        tile = 1;
        w = AIMap.GetMapSizeX();
        h = AIMap.GetMapSizeY();
        dirs = [
                [-1, 0], [1, 0], [0, -1], [0, 1]  
               ];
        coasts = AIList();
    }
}

function DelugeAI::find_water ()
{
    while (!AITile.IsWaterTile(tile))
    {
        x = AIBase.RandRange(w); 
        y = AIBase.RandRange(h); 
        tile = AIMap.GetTileIndex(x, y);
        break;
    }
}

function DelugeAI::rand_dir ()
{
    return dirs[AIBase.RandRange(4)];
}

function DelugeAI::try_lower (index)
{
    local x = AIMap.GetTileX(index);
    local y = AIMap.GetTileY(index);
    local fails = 0;

    if (is_coast(index))
    {
        if (!AITile.LowerTile(index, AITile.SLOPE_N)) fails += 1;
        if (!AITile.LowerTile(index, AITile.SLOPE_S)) fails += 1;
        if (!AITile.LowerTile(index, AITile.SLOPE_E)) fails += 1;
        if (!AITile.LowerTile(index, AITile.SLOPE_W)) fails += 1;

        if (fails == 4) return;

        Debug("lower", x, y);
        get_neighbours(x, y);
        return true;
    }

    return false;
}

function DelugeAI::get_neighbours (x, y)
{
    if (coasts.Count() > 30)
        return;

    for (local i = 0; i < 4; i ++)
    {
        local tx = x + dirs[i][0];
        local ty = y + dirs[i][1];
        local index = AIMap.GetTileIndex(tx, ty);

        if (is_coast(index) && !coasts.HasItem(index))
        {
            coasts.AddItem(index, coasts.Count());
        }
    }
}

function is_coast (index)
{
    local coast = false;

    if (AITile.IsWaterTile(index)) return false;

    if (AITile.GetMaxHeight(index) > 2) return false;
    if (AITile.GetCornerHeight(index, AITile.CORNER_N) == 0 &&
        AITile.GetCornerHeight(index, AITile.CORNER_E) == 0 &&
        AITile.GetCornerHeight(index, AITile.CORNER_S) == 0 &&
        AITile.GetCornerHeight(index, AITile.CORNER_W) == 0) return false;
    
    if (!AITile.IsBuildable(index)) return false;

    if (AITile.GetOwner(index) != AICompany.COMPANY_INVALID) return false;

    for (local i = 0; i < 4; i ++)
    {
        local tx = x + dirs[i][0];
        local ty = y + dirs[i][1];
        local index = AIMap.GetTileIndex(tx, ty);

        if (AITile.IsWaterTile(index))
        {
            coast = true;
            break;
        }
    }

    return coast;
}

function DelugeAI::Start ()
{
	AICompany.SetAutoRenewStatus(true);
	AICompany.SetAutoRenewMonths(0);
	AICompany.SetAutoRenewMoney(0);

	::COMPANY <- AICompany.ResolveCompanyID(
                    AICompany.COMPANY_SELF);
	::TICKS_PER_DAY <- 37;
    ::SLEEP_TICKS <- 5;
	::SIGN1 <- -1;
	::SIGN2 <- -1;
	::tasks <- [];

    find_water();

    Debug("found water");

    local dir = rand_dir();

	while (true)
    {
        local old = tile;

        // look for coast
        if (coasts.Count() == 0)
        {
            x += dir[0];
            y += dir[1];

            tile = AIMap.GetTileIndex(x, y);

            if (!AIMap.IsValidTile(tile))
            {
                dir = rand_dir();
                tile = old;
                x = AIMap.GetTileX(tile);
                y = AIMap.GetTileY(tile);
            }
            else
            {
                try_lower(tile);
            }
        }
        else
        {
            local index = coasts.Begin();
            while (!coasts.IsEnd())
                index = coasts.Next();

            coasts.RemoveItem(index);

            try_lower(index);
        }
	}
}

