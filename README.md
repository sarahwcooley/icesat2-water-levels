# icesat2-water-levels
These Matlab scripts are used for processing ICESat-2 ATL08 data and intersecting with a water mask to produce time series of water level. A full description of this method can be found in Cooley et al. (in review).  These scripts are all written by Sarah Cooley. If you are interested in using these scripts and/or have any questions about this approach, please contact Sarah at scooley2@uoregon.edu. 

Scripts:

1.	organize_icesat2_metadata_nov20.m: Script which uses Matlab’s h5info function to obtain metadata (i.e. bounding box, etc) for .h5 ICESat-2 track files, enabling faster processing of ICESat-2 data
2.	complete_processing_with_mask_nov20.m: Run script that creates modified water mask from GSWO occurrence product, reads in ICESat-2 data, intersects with the water mask and aggregates results to individual water bodies
3.	label_mask_and_identify_goodd_nov20.m: Function which takes the GSWO occurrence product and converts it to the conservative water mask used for intersection with ICESat-2. Also identifies reservoirs using the GOODD dam dataset amongst the water mask
4.	get_mask_metadata_func_nov20.m: Function which parses the GSWO occurrence filename into lat/lon coordinates and allows for consistent naming of output files
5.	get_merit_heights_nov20.m: Function which calculates water levels corresponding to water bodies in the water mask from the MERIT hydrography dataset
6.	get_IS2_water_data_nov20.m: Function which reads in heights from ATL08 ICESat-2 data and intersects them with the water mask
7.	organize_is2_data_nov20.m: Function which organizes heights from ATL08 ICESat-2, removes outliers and aggregates to individual water bodies
8.	organize_global_results_nov20.m: Script which organizes individual mask tile outputs of ICESat-2 water body heights into one dataset
9.	calculate_range_nov20: Script which calculates the range (seasonal variability) in water level from monthly ICESat-2 time series
10.	identify_grand_reservoirs_nov20: Script which identifies reservoirs amongst the water mask using the GRanD reservoir dataset
11.	read_in_hydrobasins_nov20: Script which aggregates results to the Hydrobasins watersheds dataset and creates global maps of seasonal water level variability and percent of total storage variability associated with reservoirs
12.	read_in_grdc_basins_nov20: Script which aggregates results to the Global River Data Center river basins dataset and creates bar figures of seasonal water level variability and percent of total storage variability associated with reservoirs
