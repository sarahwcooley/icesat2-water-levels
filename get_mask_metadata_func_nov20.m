%function to identify lat/lon of filename and parse into strings to enable
%easy naming conventions

function mask_metadata = get_mask_metadata_func_nov20(name)

    mask_metadata.name = name;
    echeck = strfind(name,'0E_');
    if isempty(echeck) == 0
        mask_metadata.ew = 'E';
        if echeck == 12
            mask_metadata.lon = str2num(name(echeck));
            mask_metadata.lonstr = ['00' (name(echeck))];
        end
        if echeck == 13
            mask_metadata.lon = str2num(name(echeck-1:echeck));
            mask_metadata.lonstr = ['0' (name(echeck-1:echeck))];
        end
        if echeck == 14
            mask_metadata.lon = str2num(name(echeck-2:echeck));
            mask_metadata.lonstr = [(name(echeck-2:echeck))];
        end
        nstart = echeck;
    end
    wcheck = strfind(name,'0W_');
    if isempty(wcheck) == 0
        mask_metadata.ew = 'W';
        if wcheck == 12
            mask_metadata.lon = str2num(name(wcheck));
            mask_metadata.lonstr = ['00' (name(wcheck))];
        end
        if wcheck == 13
            mask_metadata.lon = str2num(name(wcheck-1:wcheck));
            mask_metadata.lonstr = ['0' (name(wcheck-1:wcheck))];
        end
        if wcheck == 14
            mask_metadata.lon = str2num(name(wcheck-2:wcheck));
            mask_metadata.lonstr = [ (name(wcheck-2:wcheck))];
        end
        nstart = wcheck;
    end
    
    name_s = name(nstart:end);
    ncheck = strfind(name_s,'N_');
    if isempty(ncheck) == 0 
        mask_metadata.ns = 'N';
        if ncheck == 5
            mask_metadata.lat = str2num(name_s(ncheck - 1));
            mask_metadata.latstr = ['0' (name_s(ncheck-1))];
        end
        if ncheck == 6
            mask_metadata.lat = str2num(name_s(ncheck-2:ncheck-1));
            mask_metadata.latstr = name_s(ncheck-2:ncheck-1);
        end
    end
    scheck = strfind(name_s,'S_');
    if isempty(scheck) == 0
        mask_metadata.ns = 'S';
        if scheck == 5
            mask_metadata.lat = str2num(name_s(scheck - 1));
            mask_metadata.latstr = ['0' (name_s(scheck-1))];
        end
        if scheck == 6
            mask_metadata.lat = str2num(name_s(scheck-2:scheck-1));
            mask_metadata.latstr = name_s(scheck-2:scheck-1);
        end
    end
    
end

            
            