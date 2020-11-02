package lfsapi

import (
	"fmt"
	"sync"

	"github.com/git-lfs/git-lfs/creds"
	"github.com/git-lfs/git-lfs/errors"
	"github.com/git-lfs/git-lfs/lfshttp"
	"github.com/git-lfs/go-ntlm/ntlm"
)

type Client struct {
	Endpoints   EndpointFinder
	Credentials creds.CredentialHelper

	ntlmSessions map[string]ntlm.ClientSession
	ntlmMu       sync.Mutex

	credContext *creds.CredentialHelperContext

	client *lfshttp.Client
}

func NewClient(ctx lfshttp.Context) (*Client, error) {
	if ctx == nil {
		ctx = lfshttp.NewContext(nil, nil, nil)
	}

	gitEnv := ctx.GitEnv()
	osEnv := ctx.OSEnv()

	httpClient, err := lfshttp.NewClient(ctx)
	if err != nil {
		return nil, errors.Wrap(err, fmt.Sprintf("error creating http client"))
	}

	c := &Client{
		Endpoints:   NewEndpointFinder(ctx),
		client:      httpClient,
		credContext: creds.NewCredentialHelperContext(gitEnv, osEnv),
	}

	return c, nil
}
