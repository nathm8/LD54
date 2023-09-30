package utilities;

function normaliseTheta(theta: Float): Float {
    while (theta > 2*Math.PI) theta -= 2*Math.PI;
    while (theta < 0) theta += 2*Math.PI;
    return theta;
}