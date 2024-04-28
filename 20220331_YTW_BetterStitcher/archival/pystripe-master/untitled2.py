import numpy as np

def notch(n, sigma):
    """Generates a 1D gaussian notch filter `n` pixels long
    Parameters
    ----------
    n : int
        length of the gaussian notch filter
    sigma : float
        notch width
    Returns
    -------
    g : ndarray
        (n,) array containing the gaussian notch filter
    """
    if n <= 0:
        raise ValueError('n must be positive')
    else:
        n = int(n)
    if sigma <= 0:
        raise ValueError('sigma must be positive')
    x = np.arange(n)
    g = 1 - np.exp(-x ** 2 / (2 * sigma ** 2))
    return g


def gaussian_filter(shape, sigma):
    """Create a gaussian notch filter
    Parameters
    ----------
    shape : tuple
        shape of the output filter
    sigma : float
        filter bandwidth
    Returns
    -------
    g : ndarray
        the impulse response of the gaussian notch filter
    """
    g = notch(n=shape[-1], sigma=sigma)
    g_mask = np.broadcast_to(g, shape).copy()
    return g_mask


shape = [24, 28]
sigma = 9.518
aaa = gaussian_filter(shape, sigma)