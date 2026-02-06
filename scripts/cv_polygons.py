# Basically copying code from below that returns back just the polygons for visualization
def generate_split_polygons(lonmin=-125,
                            lonmax=-114,
                            latmin=32,
                            latmax=42.1,
                            axis = "lat",
                            numbands=10):
    # axismin/axismax is either lat or lon depending on selection
    if axis == "lat":
        axismin, axismax = latmin, latmax
    elif axis == "lon":
        axismin, axismax = lonmin, lonmax
    else:
        raise ValueError("axis must be 'lat' or 'lon'")
    # add buffer region around min, max latitude that's guaranteed to capture all
    # points in the state
    strtval, endval = math.floor(axismin*10)/10, math.floor(axismax*10)/10
    bandwidth = round((endval - strtval)/numbands,1)
    if bandwidth <= 0:
        raise ValueError("Computed bandwidth <= 0; check extents")
    # Check math!
    exclude_size = KM_2_DEG+KM_2_DEG*0.5 # max largest size of bioclim pixel is sqrt(2) ~1.5 km
    polys = {}
    for i, val in enumerate(np.arange(strtval, endval, bandwidth)[0:numbands]):

        # polygon for above the exclusion band
        # (north if axis == "lat", east if axis == "lon")
        if axis == "lat":
            toplonmax = lonmax
            toplonmin = lonmin
            toplatmax = latmax
            toplatmin = val + bandwidth
        elif axis == "lon":
            toplonmax = lonmax
            toplonmin = val + bandwidth
            toplatmax = latmax
            toplatmin = latmin
        train_top  = [Point(toplonmax, toplatmin), Point(toplonmax, toplatmax), Point(toplonmin, toplatmax),  Point(toplonmin, toplatmin)]
        train_top = Polygon(train_top)
        # polygon for below the exclusion band
        # (south if axis == "lat", west if axis == "lon")
        if axis == "lat":
            botlonmax = lonmax
            botlonmin = lonmin
            botlatmax = val
            botlatmin = latmin
        elif axis == "lon":
            botlonmax = val
            botlonmin = lonmin
            botlatmax = latmax
            botlatmin = latmin
        train_bot = [Point(botlonmax, botlatmin), Point(botlonmax, botlatmax), Point(botlonmin, botlatmax),  Point(botlonmin, botlatmin)]
        train_bot = Polygon(train_bot)
        # polygon for test locations
        # exclude_size is the buffer
        if axis == "lat":
            testlonmax = lonmax
            testlonmin = lonmin
            testlatmax = val+bandwidth-exclude_size
            testlatmin = val+exclude_size
        elif axis == "lon":
            testlonmax = val+bandwidth-exclude_size
            testlonmin = val+exclude_size
            testlatmax = latmax
            testlatmin = latmin
        test = [Point(testlonmax, testlatmin), Point(testlonmax, testlatmax), Point(testlonmin, testlatmax),  Point(testlonmin, testlatmin)]
        test = Polygon(test)
        
        # polygon for top exclusion band
        # (north if axis == "lat", east if axis == "lon")
        if axis == "lat":
            xtoplonmax = lonmax
            xtoplonmin = lonmin
            xtoplatmax = val + bandwidth
            xtoplatmin = val + bandwidth - exclude_size
        elif axis == "lon":
            xtoplonmax = val + bandwidth
            xtoplonmin = val + bandwidth - exclude_size
            xtoplatmax = latmax
            xtoplatmin = latmin
        exclude_top  = [Point(xtoplonmax, xtoplatmin), Point(xtoplonmax, xtoplatmax), Point(xtoplonmin, xtoplatmax),  Point(xtoplonmin, xtoplatmin)]
        exclude_top = Polygon(exclude_top)
        # polygon for bottom exclusion band
        # (south if axis == "lat", west if axis == "lon")
        if axis == "lat":
            xbotlonmax = lonmax
            xbotlonmin = lonmin
            xbotlatmax = val + exclude_size
            xbotlatmin = val
        elif axis == "lon":
            xbotlonmax = val + exclude_size
            xbotlonmin = val
            xbotlatmax = latmax
            xbotlatmin = latmin
        exclude_bot = [Point(xbotlonmax, xbotlatmin), Point(xbotlonmax, xbotlatmax), Point(xbotlonmin, xbotlatmax),  Point(xbotlonmin, xbotlatmin)]
        exclude_bot = Polygon(exclude_bot)

        polys[f"band_{i}"] = {
                    'train' : [train_top, train_bot],
                    'test' : test,
                    'exclusion' : [exclude_top, exclude_bot],
                }
    return polys

# make bands and exclusion zones
def make_spatial_split(daset, axisCol,
                       lonmin=-125,
                       lonmax=-114,
                       latmin=32,
                       latmax=42.1,
                       axis="lat",
                       numbands=10):
    # first, make sure we're in the right crs
    daset = daset.to_crs(naip.CRS.GBIF_CRS)
    # these are a box around the state
    # leaves a bit of a buffer around
    # the whole state
    # California:
    # lonmin, lonmax=-125,-114
    # latmin, latmax=32,42.1
    # iterate through the lat/lons in the dataset
    # iterate through this so we don't add extra bands
    # from buffer radius above
    # axismin/axismax is either lat or lon depending on selection
    if axis == "lat":
        axismin = latmin
        axismax = latmax
    elif axis == "lon":
        axismin = lonmin
        axismax = lonmax
    else:
        raise ValueError("axis must be 'lat' or 'lon'")
    # want to start either at the lowest axis value
    # or whatever 1/10 degree the most southern obs is
    strtval = max(math.floor(axismin*10)/10, math.floor(daset[axisCol].min()*10)/10)
    # want to end at either the highest axis value
    # or nearest 1/10 degree below that w/ obs
    endval = min(math.floor(axismax*10)/10, math.ceil(daset[axisCol].max()*10)/10)
    bandwidth = round((endval - strtval)/numbands,1)
    if bandwidth <= 0:
        raise ValueError("Computed bandwidth <= 0; check extents")
    for i, val in enumerate(np.arange(strtval, endval, bandwidth)[0:numbands]):
        # Check
        exclude_size = KM_2_DEG+KM_2_DEG*0.5 # max largest size of bioclim pixel is sqrt(2) ~1.5 km
        # polygon for above the exclusion band
        # (north if axis == "lat", east if axis == "lon")
        if axis == "lat":
            toplonmax = lonmax
            toplonmin = lonmin
            toplatmax = latmax
            toplatmin = val + bandwidth
        elif axis == "lon":
            toplonmax = lonmax
            toplonmin = val + bandwidth
            toplatmax = latmax
            toplatmin = latmin
        train_top  = [Point(toplonmax, toplatmin), Point(toplonmax, toplatmax), Point(toplonmin, toplatmax),  Point(toplonmin, toplatmin)]
        train_top = Polygon(train_top)
        # polygon for below the exclusion band
        # (south if axis == "lat", west if axis == "lon")
        if axis == "lat":
            botlonmax = lonmax
            botlonmin = lonmin
            botlatmax = val
            botlatmin = latmin
        elif axis == "lon":
            botlonmax = val
            botlonmin = lonmin
            botlatmax = latmax
            botlatmin = latmin
        train_bot = [Point(botlonmax, botlatmin), Point(botlonmax, botlatmax), Point(botlonmin, botlatmax),  Point(botlonmin, botlatmin)]
        train_bot = Polygon(train_bot)
        # polygon for test locations
        # exclude_size is the buffer
        if axis == "lat":
            testlonmax = lonmax
            testlonmin = lonmin
            testlatmax = val+bandwidth-exclude_size
            testlatmin = val+exclude_size
        elif axis == "lon":
            testlonmax = val+bandwidth-exclude_size
            testlonmin = val+exclude_size
            testlatmax = latmax
            testlatmin = latmin
        test = [Point(testlonmax, testlatmin), Point(testlonmax, testlatmax), Point(testlonmin, testlatmax),  Point(testlonmin, testlatmin)]
        test = Polygon(test)
        # get all the points inside train bands
        train_1 = daset[daset.intersects(train_bot)]
        train_2 = daset[daset.intersects(train_top)]
        train_pts = pd.concat([train_1, train_2]) if i != 0 else train_2
        train_pts = gpd.GeoDataFrame(train_pts, geometry=train_pts.geometry, crs=train_1.crs)
        # save which points are in train split for this band
        daset[f"train_{i}"] = False
        daset.loc[train_1.index, f"train_{i}"] = True
        daset.loc[train_2.index, f"train_{i}"] = True
        # get all points in test bands
        test_pts = daset[daset.intersects(test)]
        # save which points are in test split for this band
        # pandas will sometimes complain with a setting on slice error
        # when adding a new column this way. Annoying.
        daset[f"test_{i}"] = False
        daset.loc[test_pts.index, f"test_{i}"] = True
        # just sanity check there's no overlap
        # https://gis.stackexchange.com/questions/222315/finding-nearest-point-in-other-geodataframe-using-geopandas
        nA = np.array(list(test_pts.geometry.apply(lambda x: (x.x, x.y))))
        nB = np.array(list(train_pts.geometry.apply(lambda x: (x.x, x.y))))
        btree = cKDTree(nB)
        dist, idx = btree.query(nA, k=1)
        print(f"{len(train_pts)} training points, {len(test_pts)} testing points,  {round(len(train_pts)/len(daset)*100, 3)}% train, {round(len(test_pts)/len(daset)*100,3)}% test, {round(min(dist)/KM_2_DEG, 3)} kilometers between test and train")
    return daset
