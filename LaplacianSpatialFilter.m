function output = LaplacianSpatialFilter(output, channel, ch1, ch2, ch3, ch4)

output(:,channel) = output(:,channel) - 1/4 * (output(:,ch1) + output(:,ch2) + output(:,ch3) + output(:,ch4) );

end
