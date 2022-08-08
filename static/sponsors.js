/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * sponsors.js
 *
 * Handle OpenCollective integration
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

/**
 * Our basic API endpoints that we care for
 */
const OpenCollectiveAPI = Object.freeze(
{
    Members: 'https://opencollective.com/serpent-os/members.json',
    Project: 'https://opencollective.com/serpent-os.json'
});

window.addEventListener('load', function(ev)
{
    refreshSponsors();
});

/**
 * Refresh the sponsorship list
 */
async function refreshSponsors()
{
    refreshMembers();
    refreshProject();
}

/**
 * Render an individual member avatar
 */
function renderMember(member)
{
    const names = member.name.split(" ");
    let initials = names[0][0];
    if (names.length > 1)
    {
        initials = `${names[0][0]}${names[1][0]}`;
    }
    let styleString;
    let extraClass = '';
    if (member.image !== null)
    {
        initials = '';
        styleString = `style="background-image: url('${member.image}');" `;
    } else {
        extraClass = ' bg-azure-lt';
    }
    return `
<a target="_blank" href="${member.profile}"><span ${styleString} class="m-1 avatar rounded-circle${extraClass}">${initials}
</span></a>`;
}

/**
 * Refresh the members
 */
function refreshMembers()
{
    fetch(OpenCollectiveAPI.Members)
        .then((response) => {
            if (!response.ok)
            {
                throw new Error("Cannot update members: " + response.statusText);
            }
            return response.json();
        }).then((object) => {
            const validContributors = object.filter((element) => element.role == 'BACKER');
            document.getElementById('sponsorMembers').innerHTML =
                validContributors.map((element) => renderMember(element))
                    .join("");
        })
}

/**
 * Refresh the project stats
 */
function refreshProject()
{
    /* Our OC uses USD atm :( */
    const formatter = new Intl.NumberFormat('en-US', {
        'style': 'currency',
        'currency': 'USD'
    });
    fetch(OpenCollectiveAPI.Project)
        .then((response) => {
            if (!response.ok)
            {
                throw new Error("Cannot update project: " + response.statusText);
            }
            return response.json();
        }).then((object) => {
            document.getElementById('sponsorCount').innerHTML = object.backersCount;
            document.getElementById('sponsorBalance').innerHTML = formatter.format(object.balance / 100.0);
            document.getElementById('sponsorIncome').innerHTML = formatter.format(object.yearlyIncome / 100.0);
            console.log(object);
        });
}