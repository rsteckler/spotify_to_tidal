# Spotify to Tidal Sync - Codebase Analysis

## Project Overview
This project synchronizes music between Spotify and Tidal platforms, allowing users to maintain their playlists and favorites across both services. The codebase is written in Python and uses the official APIs of both platforms.

## Core Architecture

### Main Components
1. **sync.py** - The heart of the application
   - Handles playlist and favorites synchronization
   - Contains track matching logic
   - Manages API rate limiting and error handling
   - Key functions:
     - `sync_playlist()`: Main playlist synchronization logic
     - `sync_favorites()`: Handles favorites synchronization
     - `tidal_search()`: Searches for tracks on Tidal
     - Various matching functions (isrc_match, duration_match, name_match, artist_match)

2. **auth.py** - Authentication handling
   - Manages OAuth authentication for both platforms
   - Handles token refresh and session management

3. **cache.py** - Caching system
   - Implements caching for failed matches and track matches
   - Helps reduce API calls and improve performance

4. **tidalapi_patch.py** - Custom Tidal API extensions
   - Adds functionality to the base Tidal API
   - Includes methods for playlist management and favorites

### Key Features
1. **Track Matching Logic**
   - Uses multiple criteria for matching tracks:
     - ISRC codes (most reliable)
     - Duration matching (within 2 seconds)
     - Name matching (with normalization)
     - Artist matching (with normalization)
   - Handles various edge cases (instrumentals, remixes, etc.)

2. **Rate Limiting**
   - Implements concurrent request limiting
   - Configurable through config.yml
   - Default: 10 concurrent connections, 10 requests/second

3. **Error Handling**
   - Implements retry logic for API failures
   - Handles rate limiting errors
   - Caches failed matches to avoid repeated attempts

## Configuration
The project uses a YAML configuration file (config.yml) for:
- API credentials
- Playlist sync settings
- Rate limiting parameters
- Favorites sync preferences

## Adding Dolby Atmos Support

### Current State
- The codebase currently doesn't consider audio quality or format when matching tracks
- Track matching is based on metadata and duration only

### Implementation Strategy
To add Dolby Atmos support, we should:

1. **Modify Track Matching Logic**
   - Add a new parameter to `tidal_search()` to prefer Dolby Atmos tracks
   - Update the track matching logic in `sync.py` to consider audio quality

2. **Key Areas for Changes**
   - `tidal_search()` function in sync.py
   - Track matching logic in the `match()` function
   - Add quality preference to configuration

3. **Implementation Considerations**
   - Maintain backward compatibility
   - Add configuration option for quality preference
   - Handle cases where Dolby Atmos version isn't available
   - Consider adding a fallback mechanism

### Potential Challenges
1. Tidal API limitations in searching by audio quality
2. Need to handle cases where Dolby Atmos version has different duration
3. Potential impact on matching accuracy
4. Rate limiting considerations with additional API calls

## Best Practices for Modifications
1. Add new configuration options before modifying core logic
2. Implement changes in a way that maintains existing functionality
3. Add appropriate error handling for new features
4. Consider adding logging for quality-related decisions
5. Test thoroughly with various playlist types

## Testing Strategy
1. Test with playlists containing known Dolby Atmos tracks
2. Verify fallback behavior when Atmos version isn't available
3. Check performance impact of additional API calls
4. Validate matching accuracy with quality preferences 